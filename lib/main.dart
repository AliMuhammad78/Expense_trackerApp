import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Package imports
import 'package:money_tracker_001/theme.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';

// Screen imports
import 'package:money_tracker_001/screens/splash_screen.dart';
import 'package:money_tracker_001/screens/login_screen.dart';
import 'package:money_tracker_001/screens/register_screen.dart';
import 'package:money_tracker_001/screens/main_screen.dart';

void main() async {
  // Required for SQFlite and SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // We initialize the provider. The Splash screen will handle
        // passing the UserID to it once the app boots up.
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MoneyTrackerApp(),
    ),
  );
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,

      // Always start with the Splash Screen
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}