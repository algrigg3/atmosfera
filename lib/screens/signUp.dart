import 'package:flutter/material.dart';
import 'package:atmosfera/screens/login.dart';
import 'package:atmosfera/services/auth_service.dart'; // Import AuthService

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _signUpUser() async {
    print("Sign-up button pressed!");

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phoneNumber = _phoneController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneNumber.isEmpty) {
      print('All fields are required');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final authService = AuthService();
      final response = await authService.registerUser(
          username, email, password, phoneNumber);

      if (response.containsKey('message')) {
        print('Sign-up successful! Message: ${response['message']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up successful! Please log in.')),
        );

        // Redirect to Login Page after successful registration
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } else {
        print('Sign-up failed: ${response['error']}');
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
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildInputField(
                  "Username:", "Enter your username", _usernameController),
              SizedBox(height: 10),
              buildInputField("Email:", "Enter your email", _emailController),
              SizedBox(height: 10),
              buildInputField(
                  "Password:", "Enter your password", _passwordController,
                  obscureText: true),
              SizedBox(height: 10),
              buildInputField(
                  "Phone Number:", "XXX-XXX-XXXX", _phoneController),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signUpUser, // Calls actual signup function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .blue[900], // Use `primary` instead of `backgroundColor`
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable input field widget
Widget buildInputField(
    String label, String placeholder, TextEditingController controller,
    {bool obscureText = false}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.cyanAccent[700],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(width: 10),
        Flexible(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.white),
              contentPadding: EdgeInsets.only(bottom: 8),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
