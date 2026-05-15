import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Updated imports to match your project name
import 'package:money_tracker_001/models/transaction.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';
import 'package:money_tracker_001/theme.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with SingleTickerProviderStateMixin {
  late TabController _periodTab;
  bool _showExpenses = true;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _periodTab = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _periodTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;

    // Fetch data based on toggle - Ensure these methods exist in your Provider
    final Map<String, double> categoryData = _showExpenses
        ? provider.getExpensesByCategory(year, month)
        : provider.getIncomeByCategory(year, month);

    final total = categoryData.values.fold(0.0, (s, v) => s + v);

    // Chart Colors
    final colors = [
      kPrimaryYellow,
      const Color(0xFFFFB300),
      const Color(0xFFFFD54F),
      const Color(0xFFFFF176),
      const Color(0xFFE6EE9C),
      const Color(0xFFC0CA33),
    ];

    final sections = categoryData.entries.toList();

    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        children: [
          // 1. Yellow Header
          Container(
            color: kPrimaryYellow,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.menu, color: kBlack),
                      GestureDetector(
                        onTap: () => setState(() => _showExpenses = !_showExpenses),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: kBlack.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _showExpenses ? 'Expenses' : 'Income',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  height: 35,
                  decoration: BoxDecoration(
                    color: kBlack.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _periodTab,
                    indicator: BoxDecoration(
                      color: kBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: kPrimaryYellow,
                    unselectedLabelColor: kBlack,
                    tabs: const [
                      Tab(child: Text("Week", style: TextStyle(fontSize: 13))),
                      Tab(child: Text("Month", style: TextStyle(fontSize: 13))),
                      Tab(child: Text("Year", style: TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Horizontal Month Scroller
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _buildMonthTabs(),
            ),
          ),
          const Divider(height: 1),

          // 3. Main Content
          Expanded(
            child: total == 0
                ? _buildEmptyState()
                : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildDonutChart(sections, total, colors),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  _buildBreakdownList(sections, total, colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 60, color: kGrey),
          SizedBox(height: 12),
          Text('No data for this period', style: TextStyle(color: kGrey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDonutChart(List<MapEntry<String, double>> sections, double total, List<Color> colors) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: PieChart(
              PieChartData(
                sections: sections.asMap().entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.value,
                    color: colors[e.key % colors.length],
                    radius: 50,
                    title: '',
                    showTitle: false,
                  );
                }).toList(),
                centerSpaceRadius: 55,
                sectionsSpace: 3,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sections.length > 5 ? 5 : sections.length,
              itemBuilder: (context, i) {
                final pct = (sections[i].value / total * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(sections[i].key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                      Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownList(List<MapEntry<String, double>> sections, double total, List<Color> colors) {
    return Column(
      children: sections.asMap().entries.map((e) {
        final color = colors[e.key % colors.length];
        final pct = total > 0 ? e.value.value / total : 0.0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kPrimaryYellow.withOpacity(0.2),
                    radius: 20,
                    // Now uses the helper function from transaction.dart
                    child: Icon(getIconForCategory(e.value.key), color: kBlack, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.value.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(NumberFormat('#,###').format(e.value.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildMonthTabs() {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) months.add(DateTime(now.year, now.month - i));

    return months.map((m) {
      final isSelected = m.year == _selectedMonth.year && m.month == _selectedMonth.month;
      final label = DateFormat('MMM').format(m);
      return GestureDetector(
        onTap: () => setState(() => _selectedMonth = m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isSelected ? const Border(bottom: BorderSide(color: kPrimaryYellow, width: 3)) : null,
          ),
          child: Text(
            isSelected ? 'This Month' : label,
            style: TextStyle(color: isSelected ? kBlack : kGrey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      );
    }).toList();
  }
}