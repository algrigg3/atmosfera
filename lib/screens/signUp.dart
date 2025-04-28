import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:atmosfera/screens/login.dart';
import 'package:atmosfera/services/auth_service.dart';

import '../widgets/animated_background.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool isLoading = false;

  Future<void> _signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phoneNumber = _phoneController.text.trim();

    try {
      final authService = AuthService();
      final response = await authService.registerUser(
        username,
        email,
        password,
        phoneNumber,
      );

      if (response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up successful! Please log in.')),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['error'] ?? 'Sign-up failed. Try again.')),
        );
      }
    } catch (error) {
      print("Error signing up: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...List.generate(30, (_) => const FloatingPin(color: Colors.blue)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: Container(
                  width: 380,
                  constraints: BoxConstraints(
                    maxHeight: double.infinity, // no forced height
                  ),
                  child: Stack(children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedBackground(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blue.shade900, width: 3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildInputField(
                              label: "Username:",
                              placeholder: "Enter your username",
                              controller: _usernameController,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Username is required'
                                      : null,
                            ),
                            SizedBox(height: 10),
                            buildInputField(
                              label: "Email:",
                              placeholder: "Enter your email",
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Email is required';
                                final emailRegex =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                                return emailRegex.hasMatch(value)
                                    ? null
                                    : 'Enter a valid email';
                              },
                            ),
                            SizedBox(height: 10),
                            buildInputField(
                              label: "Password:",
                              placeholder: "Enter your password",
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) =>
                                  value == null || value.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                            ),
                            SizedBox(height: 10),
                            buildInputField(
                              label: "Confirm Password:",
                              placeholder: "Re-enter password",
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            buildInputField(
                              label: "Phone:",
                              placeholder: "XXX-XXX-XXXX",
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Phone number is required'
                                      : null,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isLoading ? null : _signUpUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])),
            ),
          ),
        )
      ],
    );
  }
}

// Reusable input field widget
Widget buildInputField({
  required String label,
  required String placeholder,
  required TextEditingController controller,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blue[900], fontSize: 16),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle:
                  TextStyle(color: const Color.fromARGB(151, 13, 72, 161)),
              suffixIcon: suffixIcon ?? SizedBox(width: 0, height: 0),
              contentPadding: EdgeInsets.only(bottom: 8),
            ),
            style: TextStyle(color: Colors.blue[900]),
          ),
        ),
      ],
    ),
  );
}
