import 'package:flutter/material.dart';
import 'package:money_tracker_001/theme.dart';
import 'package:money_tracker_001/data/database_helper.dart';
import 'package:money_tracker_001/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim().toLowerCase();

      User newUser = User(
        username: nameController.text.trim(),
        email: email,
        password: passwordController.text,
      );

      try {
        final db = DatabaseHelper();

        bool alreadyExists = await db.checkEmailExists(email);
        if (alreadyExists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This email is already registered"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        await db.registerUser(newUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created Successfully! Please Login."),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        debugPrint("Registration Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kBlack,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Join the Expense Tracker",
                style: TextStyle(color: kGrey),
              ),
              const SizedBox(height: 40),

              buildField(
                nameController,
                "Full Name",
                Icons.person,
                action: TextInputAction.next, // Moves to Email
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your name";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              buildField(
                emailController,
                "Email Address",
                Icons.email,
                action: TextInputAction.next, // Moves to Password
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter an email";
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
                Icons.lock,
                isPassword: true,
                action: TextInputAction.done, // Shows "Done" button
                onSubmit: (_) => registerUser(), // Triggers registration on Enter
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter a password";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryYellow,
                    foregroundColor: kBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: registerUser,
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: kBlack),
                ),
              ),
            ],
          ),
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
        Function(String)? onSubmit}
      ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: kBlack),
      validator: validator,
      textInputAction: action, // Keyboard action (Next/Done)
      onFieldSubmitted: onSubmit, // Action when keyboard enter is pressed
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}