import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final now = DateTime.now();

    // Monthly data
    final expenses = provider.getMonthlyExpenses(now.year, now.month);
    final income = provider.getMonthlyIncome(now.year, now.month);
    final balance = provider.getMonthlyBalance(now.year, now.month);
    final budget = provider.monthlyBudget;
    final remaining = budget - expenses;
    final budgetPct = budget > 0 ? (expenses / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        children: [
          // 1. Refined Yellow Header
          Container(
            color: kPrimaryYellow,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
            child: Column(
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kBlack),
                ),
                const SizedBox(height: 12),
                // Custom Styled TabBar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBlack.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: kBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: kPrimaryYellow,
                    unselectedLabelColor: kBlack,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Analytics'),
                      Tab(text: 'Accounts'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Tab Content
          Expanded(
            child: _tabController.index == 0
                ? _buildAnalytics(expenses, income, balance, budget, remaining, budgetPct, provider)
                : _buildAccounts(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(
      double expenses,
      double income,
      double balance,
      double budget,
      double remaining,
      double budgetPct,
      TransactionProvider provider,
      ) {
    final now = DateTime.now();
    final fmt = NumberFormat('#,###');

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Monthly Statistics Card
        _Card(
          title: "Monthly Statistics",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatCol(label: 'Expenses', value: fmt.format(expenses), valueColor: Colors.red),
              _StatCol(label: 'Income', value: fmt.format(income), valueColor: Colors.green),
              _StatCol(label: 'Balance', value: fmt.format(balance), valueColor: kBlack),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Monthly Budget Card
        _Card(
          title: "Monthly Budget",
          child: Column(
            children: [
              Row(
                children: [
                  // Modern Budget Progress Circle
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: budgetPct,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              budgetPct > 0.9 ? Colors.red : kPrimaryYellow),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              budget == 0 ? '0%' : '${(budgetPct * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Used', style: TextStyle(fontSize: 10, color: kGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Budget Details
                  Expanded(
                    child: Column(
                      children: [
                        _BudgetRow(label: 'Remaining', value: fmt.format(remaining), color: Colors.green),
                        const Divider(height: 20),
                        _BudgetRow(label: 'Budget', value: fmt.format(budget), color: kBlack),
                        const SizedBox(height: 8),
                        _BudgetRow(label: 'Expenses', value: fmt.format(expenses), color: Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryYellow,
                    foregroundColor: kBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _setBudget(context, provider),
                  child: const Text('Edit Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setBudget(BuildContext context, TransactionProvider provider) {
    _budgetController.text = provider.monthlyBudget > 0 ? provider.monthlyBudget.toStringAsFixed(0) : '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: 'Rs. ',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: kGrey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: kBlack),
            onPressed: () {
              final v = double.tryParse(_budgetController.text);
              if (v != null) provider.setMonthlyBudget(v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccounts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.account_balance_wallet_outlined, size: 60, color: kLightGrey),
          SizedBox(height: 12),
          Text('Accounts feature coming soon!', style: TextStyle(color: kGrey, fontSize: 16)),
        ],
      ),
    );
  }
}

// --- HELPER UI WIDGETS ---

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Icon(Icons.arrow_forward_ios, size: 12, color: kGrey),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _StatCol({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kGrey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor)),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BudgetRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kGrey, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ],
    );
  }
}