import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String phone_number = _phoneController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone_number.isEmpty) {
      print('All fields are required');
      print('Username: ${_usernameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Phone Number: ${_phoneController.text}');
      return; // Stop if any field is empty
    }

    final url = Uri.parse('http://127.0.0.1:3000/signup'); //Backend API
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "email": email,
        "password": password,
        "phone_number": phone_number,
      }),
    );
    print('Response Status: ${response.statusCode}');
    print('response body: ${response.body}');
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
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildInputField("Username:", "username", _usernameController),
              SizedBox(height: 10),
              buildInputField("Email:", "email", _emailController),
              SizedBox(height: 10),
              buildInputField("Password:", "password", _passwordController,
                  obscureText: true),
              SizedBox(height: 10),
              buildInputField(
                  "Phone Number:", "XXX-XXX-XXXX", _phoneController),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signUpUser, //call function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Sign up',
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

Widget buildInputField(
    String label, String placeholder, TextEditingController usernameController,
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
        SizedBox(width: 10), // Space between label and TextField
        Flexible(
            child: TextField(
          controller: usernameController,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.only(bottom: 8),
          ),
          style: TextStyle(color: Colors.white),
        )),
      ],
    ),
  );
}
