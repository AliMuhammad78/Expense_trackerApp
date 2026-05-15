import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Package imports matched to your project name
import 'package:money_tracker_001/models/transaction.dart';
import 'package:money_tracker_001/data/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  double _monthlyBudget = 0;
  int? _currentUserId;
  final _uuid = const Uuid();
  final DatabaseHelper _db = DatabaseHelper();

  List<Transaction> get transactions => _transactions;
  double get monthlyBudget => _monthlyBudget;

  // Constructor
  TransactionProvider({int? authUserId}) {
    _currentUserId = authUserId;
    if (_currentUserId != null) {
      _loadData();
    }
  }

  // Sets the user and reloads data (called during Login/Splash)
  void setCurrentUser(int userId) {
    _currentUserId = userId;
    _loadData();
  }

  /// Loads only the transactions belonging to the current user
  Future<void> _loadData() async {
    if (_currentUserId == null) return;

    try {
      final List<Map<String, dynamic>> maps = await _db.getExpensesByUser(_currentUserId!);

      _transactions = maps.map((e) => Transaction.fromMap(e)).toList();

      // Sort by date: Newest first
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  /// Adds a new transaction linked to the current user
  Future<void> addTransaction({
    required String categoryId,
    required String categoryName,
    required IconData categoryIcon,
    required double amount,
    required DateTime date,
    required String note,
    required TransactionType type,
  }) async {
    if (_currentUserId == null) return;

    // FIX: Pass _currentUserId directly to the Transaction constructor
    final tx = Transaction(
      id: _uuid.v4(),
      userId: _currentUserId,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      amount: amount,
      date: date,
      note: note,
      type: type,
    );

    // 1. Update Local State
    _transactions.add(tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    // 2. Persist to Database
    try {
      final dbData = await _db.database;
      // tx.toMap() now includes the userId automatically because of our model update
      await dbData.insert('expenses', tx.toMap());
    } catch (e) {
      debugPrint("Error saving transaction: $e");
    }

    notifyListeners();
  }

  /// Deletes a transaction by ID
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);

    try {
      final dbData = await _db.database;
      await dbData.delete('expenses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    }

    notifyListeners();
  }

  // --- Budget Management ---

  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  // --- Filtering & Math Logic ---

  List<Transaction> getByMonth(int year, int month) {
    return _transactions.where(
          (t) => t.date.year == year && t.date.month == month,
    ).toList();
  }

  double getMonthlyExpenses(int year, int month) {
    return getByMonth(year, month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyIncome(int year, int month) {
    return getByMonth(year, month)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyBalance(int year, int month) {
    return getMonthlyIncome(year, month) - getMonthlyExpenses(year, month);
  }

  Map<String, double> getExpensesByCategory(int year, int month) {
    final expenses = getByMonth(year, month)
        .where((t) => t.type == TransactionType.expense);
    final Map<String, double> result = {};
    for (final tx in expenses) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return result;
  }

  Map<String, double> getIncomeByCategory(int year, int month) {
    final income = getByMonth(year, month)
        .where((t) => t.type == TransactionType.income);
    final Map<String, double> result = {};
    for (final tx in income) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return result;
  }

  Map<DateTime, List<Transaction>> getGroupedByDay(int year, int month) {
    final txs = getByMonth(year, month);
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(day, () => []).add(tx);
    }
    return grouped;
  }
}