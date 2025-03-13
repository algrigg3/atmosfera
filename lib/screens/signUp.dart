import 'package:flutter/material.dart';
import 'package:atmosfera/screens/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  //Mock signup function (no backend)
  Future<void> _signUpUser() async {
    print("Sign-up button pressed (MOCK)");

    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String phone_number = _phoneController.text.trim();

    //Check if any field is empty
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone_number.isEmpty) {
      print('All fields are required (MOCK)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    //MOCK success logic (replace with real backend later)
    print('Mock Signup successful!');
    print('Username: $username');
    print('Email: $email');
    print('Password: $password');
    print('Phone: $phone_number');

    /*final url =
    Uri.parse('http://192.168.1.70:5000/api/auth/signup'); // Backend API
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

        if (response.statusCode == 201) {
          print('Signup successful! ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup successful! Please log in.')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          print('Signup failed: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Signup failed: ${jsonDecode(response.body)['message'] ?? 'Try again.'}')),
          );
        }

    */
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup successful! Please log in.')),
    );

    //Navigate to LoginPage after mock signup
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
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
                onPressed: _signUpUser, // Call mock signup
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

//Reusable input field widget
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
