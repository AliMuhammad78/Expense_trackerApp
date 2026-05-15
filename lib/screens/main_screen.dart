import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'charts_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Current index for the BottomNavigationBar
  int _currentIndex = 0;

  // We map the _currentIndex to the actual index in the IndexedStack
  int _getStackIndex(int index) {
    if (index < 2) return index;
    if (index > 2) return index - 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: Prevents keyboard from pushing the navigation bar up and causing overflows
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      body: IndexedStack(
        index: _getStackIndex(_currentIndex),
        children: const [
          HomeScreen(),
          ChartsScreen(),
          ReportsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: kWhite,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        // FIX: Replaced fixed height SizedBox with a flexible Padding to stop overflow
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.format_list_bulleted,
                  label: 'Home',
                  active: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(
                  icon: Icons.pie_chart_outline,
                  label: 'Charts',
                  active: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1)),

              // Spacing for the FloatingActionButton in the center
              const SizedBox(width: 48),

              _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Reports',
                  active: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3)),
              _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  active: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryYellow,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
              fullscreenDialog: true,
            ),
          );
        },
        child: const Icon(Icons.add, color: kBlack, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min, // FIX: Minimizes height to prevent overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? kPrimaryYellow : kGrey, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: active ? kPrimaryYellow : kGrey,
                    fontSize: 11,
                    fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}