import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Category? _selectedCategory;
  String _amount = '0';
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() => setState(() {
      _selectedCategory = null;
      _amount = '0';
      _noteController.clear();
    }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  TransactionType get _currentType {
    switch (_tabController.index) {
      case 0: return TransactionType.expense;
      case 1: return TransactionType.income;
      default: return TransactionType.transfer;
    }
  }

  List<Category> get _currentCategories {
    return _currentType == TransactionType.expense
        ? expenseCategories
        : incomeCategories;
  }

  void _onKeyTap(String val) {
    setState(() {
      if (val == '⌫') {
        if (_amount.length <= 1) {
          _amount = '0';
        } else {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (val == '.') {
        if (!_amount.contains('.')) _amount += '.';
      } else {
        if (_amount == '0') {
          _amount = val;
        } else {
          _amount += val;
        }
      }
    });
  }

  void _save() {
    final doubleAmount = double.tryParse(_amount) ?? 0.0;
    if (_selectedCategory == null || doubleAmount <= 0) return;

    context.read<TransactionProvider>().addTransaction(
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon,
      amount: doubleAmount,
      date: _selectedDate,
      note: _noteController.text,
      type: _currentType,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        children: [
          // Header
          Container(
            color: kPrimaryYellow,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: kBlack, fontSize: 16)),
                      ),
                      const Expanded(
                        child: Center(child: Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      ),
                      IconButton(icon: const Icon(Icons.currency_exchange), onPressed: () {}),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBlack.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(6)),
                    labelColor: kPrimaryYellow,
                    unselectedLabelColor: kBlack,
                    tabs: const [Tab(text: 'Expense'), Tab(text: 'Income'), Tab(text: 'Transfer')],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
              ),
              itemCount: _currentCategories.length + 1,
              itemBuilder: (ctx, i) {
                if (i == _currentCategories.length) {
                  return _CategoryItem(icon: Icons.add, label: 'Settings', isSelected: false, onTap: () {});
                }
                final cat = _currentCategories[i];
                return _CategoryItem(
                  icon: cat.icon,
                  label: cat.name,
                  isSelected: _selectedCategory?.id == cat.id,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _showNumericKeypad(cat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNumericKeypad(Category cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF2F2F7),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Display Area
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.contact_page_outlined, color: kGrey, size: 28),
                        Text(_amount, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text("Note : ", style: TextStyle(color: kGrey)),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(hintText: "Enter a note...", border: InputBorder.none),
                          ),
                        ),
                        const Icon(Icons.camera_alt_outlined, color: kGrey),
                      ],
                    ),
                  ],
                ),
              ),
              // Custom Keypad
              Container(
                padding: const EdgeInsets.all(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0', '⌫'].map((key) {
                            return _KeyButton(
                              label: key,
                              onTap: () {
                                _onKeyTap(key);
                                setModalState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _KeyButton(
                            label: "Today",
                            icon: Icons.calendar_today,
                            color: Colors.white,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setModalState(() => _selectedDate = picked);
                            },
                          ),
                          _KeyButton(label: "+", color: Colors.white, onTap: () {}),
                          _KeyButton(label: "-", color: Colors.white, onTap: () {}),
                          _KeyButton(
                            label: "✓",
                            color: const Color(0xFFC4C4C4),
                            height: 80,
                            onTap: () {
                              Navigator.pop(ctx);
                              _save();
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;
  final double? height;

  const _KeyButton({required this.label, this.icon, required this.onTap, this.color = Colors.white, this.height});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 55,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 18, color: kPrimaryYellow),
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryYellow : const Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade700, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }
}