import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// These must match the 'name' field in your pubspec.yaml exactly
import 'package:money_tracker_001/models/transaction.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';
import 'package:money_tracker_001/theme.dart';
import 'package:money_tracker_001/screens/transaction_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _showMonthPicker() async {
    showDialog(
      context: context,
      builder: (ctx) {
        int year = _selectedMonth.year;
        int month = _selectedMonth.month;
        return StatefulBuilder(builder: (context, setS) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => setS(() => year--), icon: const Icon(Icons.chevron_left)),
                Text('$year'),
                IconButton(onPressed: () => setS(() => year++), icon: const Icon(Icons.chevron_right)),
              ],
            ),
            content: SizedBox(
              width: 300,
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final m = i + 1;
                  final isSelected = m == month && year == _selectedMonth.year;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMonth = DateTime(year, m);
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(DateFormat('MMM').format(DateTime(2000, m))),
                    ),
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    // FIX: Removed the Scaffold and BottomAppBar from here.
    // The MainScreen already provides the Scaffold and Navigation Bar.
    // Returning the list directly prevents the "Double Bottom Bar" issue.
    return _buildHomeList(provider);
  }

  Widget _buildHomeList(TransactionProvider provider) {
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;
    final expenses = provider.getMonthlyExpenses(year, month);
    final income = provider.getMonthlyIncome(year, month);
    final balance = provider.getMonthlyBalance(year, month);
    final grouped = provider.getGroupedByDay(year, month);
    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      color: kWhite,
      child: Column(
        children: [
          Container(
            color: kPrimaryYellow,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu, size: 26),
                    const Expanded(child: Center(child: Text('Money Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
                    IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearch(context, provider)),
                    IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed: _showMonthPicker),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$year', style: TextStyle(color: kBlack.withOpacity(0.6), fontSize: 13)),
                          GestureDetector(
                            onTap: _showMonthPicker,
                            child: Row(
                              children: [
                                Text(DateFormat('MMMM').format(_selectedMonth), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const Icon(Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _SummaryColumn(label: 'Expenses', value: _fmt(expenses), color: kBlack),
                    const SizedBox(width: 12),
                    _SummaryColumn(label: 'Income', value: _fmt(income), color: kBlack),
                    const SizedBox(width: 12),
                    _SummaryColumn(label: 'Balance', value: _fmt(balance), color: kBlack),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedDays.isEmpty
                ? const Center(child: Text('No transactions yet.\nTap + to add one.', textAlign: TextAlign.center, style: TextStyle(color: kGrey, fontSize: 16)))
                : ListView.builder(
              itemCount: sortedDays.length,
              itemBuilder: (ctx, i) {
                final day = sortedDays[i];
                final txs = grouped[day]!;
                final dayExp = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          Text('${DateFormat('MMM d').format(day)}  ${DateFormat('EEEE').format(day)}', style: const TextStyle(color: kGrey, fontSize: 13)),
                          const Spacer(),
                          if (dayExp > 0) Text('Expenses: ${_fmt(dayExp)}', style: const TextStyle(color: kGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...txs.map((tx) => _TransactionTile(tx: tx)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, TransactionProvider provider) {
    showSearch(context: context, delegate: _TransactionSearch(provider));
  }

  String _fmt(double v) => NumberFormat('#,###').format(v.abs());
}

class _SummaryColumn extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailsScreen(transaction: tx),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: kPrimaryYellow.withOpacity(0.2),
        child: Icon(tx.categoryIcon, color: kBlack, size: 20),
      ),
      title: Text(tx.note.isEmpty ? tx.categoryName : tx.note, style: const TextStyle(fontSize: 15)),
      trailing: Text(
        isExpense ? '-${NumberFormat('#,###').format(tx.amount)}' : NumberFormat('#,###').format(tx.amount),
        style: TextStyle(color: isExpense ? kBlack : Colors.green, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TransactionSearch extends SearchDelegate<String> {
  final TransactionProvider provider;
  _TransactionSearch(this.provider);

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  @override
  Widget buildResults(BuildContext context) => _buildList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = provider.transactions.where((t) => t.categoryName.toLowerCase().contains(query.toLowerCase()) || t.note.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(itemCount: results.length, itemBuilder: (ctx, i) => _TransactionTile(tx: results[i]));
  }
}