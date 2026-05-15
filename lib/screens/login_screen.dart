import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker_001/theme.dart';
import 'package:money_tracker_001/data/database_helper.dart';
import 'package:money_tracker_001/models/user.dart';
import 'package:money_tracker_001/providers/transaction_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper();
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      try {
        bool userExists = await db.checkEmailExists(email);

        if (!userExists) {
          if (mounted) {
            _showErrorSnackBar("User does not exist. Please register first.");
          }
          return;
        }

        final User? user = await db.loginUser(email, password);

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', user.id!);

          if (mounted) {
            context.read<TransactionProvider>().setCurrentUser(user.id!);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome back, ${user.username}!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          if (mounted) {
            _showErrorSnackBar("Incorrect password. Please try again.");
          }
        }
      } catch (e) {
        debugPrint("Login Error: $e");
        if (mounted) {
          _showErrorSnackBar("An error occurred during login");
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimaryYellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: kBlack,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Money Tracker",
                    style: TextStyle(
                      fontSize: 26,
                      color: kBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kBlack,
                      ),
                    ),
                    const Text(
                      "Log in to manage your expenses",
                      style: TextStyle(color: kGrey),
                    ),

                    const SizedBox(height: 30),

                    buildField(
                      emailController,
                      "Email Address",
                      Icons.email_outlined,
                      action: TextInputAction.next, // Jumps to password field
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter your email";
                        final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value);
                        if (!emailValid) return "Enter a valid email address";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    buildField(
                      passwordController,
                      "Password",
                      Icons.lock_outline,
                      isPassword: true,
                      action: TextInputAction.done, // Shows "Done/Go" icon
                      onSubmit: (_) => loginUser(), // Submits form on Enter
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter your password";
                        if (value.length < 6) return "Password is too short";
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryYellow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: loginUser,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kBlack,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Don't have an account? Create one",
                          style: TextStyle(color: kBlack, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(
      TextEditingController controller,
      String hint,
      IconData icon,
      {bool isPassword = false,
        String? Function(String?)? validator,
        TextInputAction? action,
        Function(String)? onSubmit}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: kBlack),
      validator: validator,
      textInputAction: action, // Keyboard action logic
      onFieldSubmitted: onSubmit, // Logic for the Enter key
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kGrey),
        hintText: hint,
        hintStyle: const TextStyle(color: kGrey),
        filled: true,
        fillColor: kLightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}