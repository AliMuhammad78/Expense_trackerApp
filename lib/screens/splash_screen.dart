import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker_001/theme.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // The Logic: Always show splash, then check session
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 1. Wait for the splash animation/time
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // 2. Check SharedPreferences for an existing session
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    if (userId != null) {
      // 3. User is logged in: Tell the provider who it is and go Home
      // This ensures data is NOT lost and is loaded correctly
      if (mounted) {
        context.read<TransactionProvider>().setCurrentUser(userId);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // 4. No user logged in: Go to Login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryYellow, // Solid brand color background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minimalist Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kBlack,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: kBlack.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: kPrimaryYellow,
                  size: 55,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Money Tracker',
                style: TextStyle(
                  color: kBlack,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Track your expenses & income',
                style: TextStyle(
                  color: kBlack.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              // Subtle loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: kBlack,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}