import 'package:flutter/material.dart';

enum TransactionType { expense, income, transfer }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final TransactionType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
  });
}

class Transaction {
  final String id;
  final int? userId; // NEW: Link to the owner of the transaction
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;

  Transaction({
    required this.id,
    this.userId, // Added userId
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
  });

  // Converts a Transaction into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // CRITICAL: This was missing!
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconCode': categoryIcon.codePoint,
      'categoryIconFont': categoryIcon.fontFamily,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'type': type.index,
    };
  }

  // Extracts a Transaction object from a Map.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'], // Added userId
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      categoryIcon: IconData(
        map['categoryIconCode'],
        fontFamily: map['categoryIconFont'] ?? 'MaterialIcons',
      ),
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      type: TransactionType.values[map['type']],
    );
  }
}

// Helper function to find icons by name for the Charts screen
IconData getIconForCategory(String categoryName) {
  final allCategories = [...expenseCategories, ...incomeCategories];
  try {
    return allCategories.firstWhere((cat) => cat.name == categoryName).icon;
  } catch (e) {
    return Icons.category_outlined; // Fallback icon
  }
}

// Expense categories list
const List<Category> expenseCategories = [
  Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_cart_outlined, type: TransactionType.expense),
  Category(id: 'food', name: 'Food', icon: Icons.restaurant_outlined, type: TransactionType.expense),
  Category(id: 'phone', name: 'Phone', icon: Icons.phone_android_outlined, type: TransactionType.expense),
  Category(id: 'entertainment', name: 'Entertainment', icon: Icons.sports_esports_outlined, type: TransactionType.expense),
  Category(id: 'education', name: 'Education', icon: Icons.school_outlined, type: TransactionType.expense),
  Category(id: 'beauty', name: 'Beauty', icon: Icons.content_cut_outlined, type: TransactionType.expense),
  Category(id: 'sports', name: 'Sports', icon: Icons.directions_run_outlined, type: TransactionType.expense),
  Category(id: 'social', name: 'Social', icon: Icons.people_outline, type: TransactionType.expense),
  Category(id: 'transportation', name: 'Transportation', icon: Icons.directions_bus_outlined, type: TransactionType.expense),
  Category(id: 'clothing', name: 'Clothing', icon: Icons.checkroom_outlined, type: TransactionType.expense),
  Category(id: 'car', name: 'Car', icon: Icons.directions_car_outlined, type: TransactionType.expense),
  Category(id: 'alcohol', name: 'Alcohol', icon: Icons.wine_bar_outlined, type: TransactionType.expense),
  Category(id: 'cigarettes', name: 'Cigarettes', icon: Icons.smoke_free_outlined, type: TransactionType.expense),
  Category(id: 'electronics', name: 'Electronics', icon: Icons.desktop_windows_outlined, type: TransactionType.expense),
  Category(id: 'travel', name: 'Travel', icon: Icons.airplanemode_active_outlined, type: TransactionType.expense),
  Category(id: 'health', name: 'Health', icon: Icons.favorite_border, type: TransactionType.expense),
  Category(id: 'pets', name: 'Pets', icon: Icons.pets_outlined, type: TransactionType.expense),
  Category(id: 'repairs', name: 'Repairs', icon: Icons.build_outlined, type: TransactionType.expense),
  Category(id: 'housing', name: 'Housing', icon: Icons.home_outlined, type: TransactionType.expense),
  Category(id: 'home', name: 'Home', icon: Icons.weekend_outlined, type: TransactionType.expense),
  Category(id: 'gifts', name: 'Gifts', icon: Icons.card_giftcard_outlined, type: TransactionType.expense),
  Category(id: 'donations', name: 'Donations', icon: Icons.volunteer_activism_outlined, type: TransactionType.expense),
  Category(id: 'lottery', name: 'Lottery', icon: Icons.casino_outlined, type: TransactionType.expense),
  Category(id: 'snacks', name: 'Snacks', icon: Icons.local_movies_outlined, type: TransactionType.expense),
  Category(id: 'kids', name: 'Kids', icon: Icons.child_friendly_outlined, type: TransactionType.expense),
  Category(id: 'vegetables', name: 'Vegetables', icon: Icons.energy_savings_leaf_outlined, type: TransactionType.expense),
  Category(id: 'fruits', name: 'Fruits', icon: Icons.apple_outlined, type: TransactionType.expense),
];

// Income categories list
const List<Category> incomeCategories = [
  Category(id: 'salary', name: 'Salary', icon: Icons.work_outline, type: TransactionType.income),
  Category(id: 'investments', name: 'Investments', icon: Icons.trending_up_outlined, type: TransactionType.income),
  Category(id: 'parttime', name: 'Part-Time', icon: Icons.handshake_outlined, type: TransactionType.income),
  Category(id: 'bonus', name: 'Bonus', icon: Icons.emoji_events_outlined, type: TransactionType.income),
  Category(id: 'others_income', name: 'Others', icon: Icons.monetization_on_outlined, type: TransactionType.income),
];