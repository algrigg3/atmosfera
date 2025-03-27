import 'package:atmosfera/screens/theNow.dart';
import 'package:flutter/material.dart';
import 'package:atmosfera/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    print("Login button pressed!");

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    print('Username: $username'); // Debugging
    print('Password: $password');

    if (username.isEmpty || password.isEmpty) {
      print('Both fields are required');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Both username and password are required')),
      );
      return;
    }

    try {
      final authService = AuthService();
      final response = await authService.loginUser(username, password);

      if (response.containsKey('token') && response.containsKey('userId')) {
        print('Login Successful! Token: ${response['token']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Redirecting...')),
        );

        // Ensure userId is valid before navigating
        final String userId = response['userId'];
        if (userId.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TheNow(userId: userId)),
          );
        } else {
          print('Error: Received empty userId');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: User ID missing')),
          );
        }
      } else {
        print('Login failed: ${response['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Login failed')),
        );
      }
    } catch (error) {
      print("Error logging in: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade900, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildInputField(
                    "Username:", "Enter your username", _usernameController),
                const SizedBox(height: 10),
                buildInputField(
                    "Password:", "Enter your password", _passwordController,
                    obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Input Field Widget
Widget buildInputField(
  String label,
  String placeholder,
  TextEditingController controller, {
  bool obscureText = false,
}) {
  return Container(
    height: 60, // 🟦 give it height to avoid cramping
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.cyanAccent[700],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            overflow: TextOverflow.ellipsis, // ensures no wrapping
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '',
              contentPadding: EdgeInsets.only(bottom: 8),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
