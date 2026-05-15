import 'package:flutter/material.dart';

// --- Color Constants ---
const kPrimaryYellow = Color(0xFFFFC107);
const kDarkYellow = Color(0xFFF5A623);
const kBlack = Color(0xFF1A1A1A);
const kGrey = Color(0xFF9E9E9E);
const kLightGrey = Color(0xFFF5F5F5);
const kWhite = Color(0xFFFFFFFF);

// --- Theme Provider (The Logic) ---
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme() : appTheme();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // This tells the app to rebuild with new colors
  }
}

// --- Light Theme ---
ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: kPrimaryYellow,
    scaffoldBackgroundColor: kWhite,
    colorScheme: const ColorScheme.light(
      primary: kPrimaryYellow,
      secondary: kDarkYellow,
      surface: kWhite,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryYellow,
      foregroundColor: kBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: kBlack,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kWhite,
      selectedItemColor: kPrimaryYellow,
      unselectedItemColor: kGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

// --- Dark Theme ---
ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: kPrimaryYellow,
    scaffoldBackgroundColor: kBlack,
    colorScheme: const ColorScheme.dark(
      primary: kPrimaryYellow,
      secondary: kDarkYellow,
      surface: Color(0xFF2C2C2C), // Slightly lighter than kBlack for cards
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C2C2C),
      foregroundColor: kPrimaryYellow,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: kPrimaryYellow,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBlack,
      selectedItemColor: kPrimaryYellow,
      unselectedItemColor: kGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}