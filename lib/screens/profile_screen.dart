import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for logout logic
import 'package:money_tracker_001/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access your ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : kWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: _buildProfileHeader(isDark),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPremiumCard(isDark),
                  const SizedBox(height: 24),

                  // Section 1: Interaction
                  _buildMenuCard(context, isDark, [
                    _MenuItem(Icons.thumb_up_outlined, 'Recommend to Friends', () {}),
                    _MenuItem(Icons.block_outlined, 'Block Ads', () {}),
                    _MenuItem(Icons.settings_outlined, 'Settings', () => _showSettings(context, themeProvider)),
                    _MenuItem(Icons.apps_outlined, 'Our Other Apps', () {}, badge: true),
                  ]),

                  const SizedBox(height: 16),

                  // Section 2: Preferences
                  _buildMenuCard(context, isDark, [
                    _MenuItem(Icons.currency_exchange, 'Currency', () {}),
                    _MenuItem(Icons.notifications_outlined, 'Notifications', () {}),
                    _MenuItem(Icons.backup_outlined, 'Backup & Restore', () {}),
                    _MenuItem(Icons.lock_outline, 'App Lock', () {}),
                  ]),

                  const SizedBox(height: 16),

                  // Section 3: App Info
                  _buildMenuCard(context, isDark, [
                    _MenuItem(Icons.info_outline, 'About', () {}),
                    _MenuItem(Icons.star_outline, 'Rate Us', () {}),
                    _MenuItem(Icons.logout, 'Logout', () async {
                      // NEW LOGOUT LOGIC
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId'); // Removes session but retains DB data

                      if (context.mounted) {
                        // Clears navigation stack and goes to login
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    }),
                  ]),

                  const SizedBox(height: 30), // Bottom padding for scroll
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimaryYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: kBlack,
            child: Icon(Icons.person, color: kPrimaryYellow, size: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muhammad Ali',
                style: GoogleFonts.roboto(
                  color: kBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'University of Gujrat',
                style: TextStyle(color: Color(0x991A1A1A), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBlack,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: kPrimaryYellow, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Enjoy ad-free experience',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kPrimaryYellow),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, bool isDark, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: kPrimaryYellow, size: 22),
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : kBlack,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: kGrey, size: 18),
              ),
              if (i < items.length - 1)
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12, indent: 60),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showSettings(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: kGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined, color: kPrimaryYellow),
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeColor: kPrimaryYellow,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language_outlined, color: kPrimaryYellow),
              title: const Text('Language', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Text('English', style: TextStyle(color: kGrey)),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool badge;

  _MenuItem(this.icon, this.label, this.onTap, {this.badge = false});
}