import 'package:flutter/material.dart';

class signUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildInputField("Username:", "username"),
              SizedBox(height: 10),
              buildInputField("Email:", "email"),
              SizedBox(height: 10),
              buildInputField("Password:", "password"),
              SizedBox(height: 10),
              buildInputField("Phone Number:", "XXX-XXX-XXXX"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  //add sign up logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

Widget buildInputField(String label, String placeholder,
    {bool obscureText = false}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.teal,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Expanded(
            child: TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.white)),
          style: TextStyle(color: Colors.white),
        ))
      ],
    ),
  );
}
