import 'package:flutter/material.dart';
import 'package:atmosfera/screens/theNow.dart';
import 'package:atmosfera/services/auth_service.dart';
import 'package:atmosfera/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/animated_background.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.loginUser(username, password);

      if (response.containsKey('token') && response.containsKey('userId')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', response['token']);
        await prefs.setString('userId', response['userId']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful! Redirecting...')),
        );

        final String userId = response['userId'];

        if (userId.isNotEmpty) {
          SocketService().initSocket(userId);

          SocketService().onNotification((data) {
            print('Received Notification: $data');
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TheNow(userId: userId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: User ID missing')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Login failed')),
        );
      }
    } catch (error) {
      print("Error logging in: $error");
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
    _passwordController.dispose();
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
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade900, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildInputField(
                        label: "Username:",
                        placeholder: "Enter your username",
                        controller: _usernameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Username required'
                            : null,
                      ),
                      const SizedBox(height: 10),
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
                        validator: (value) => value == null || value.isEmpty
                            ? 'Password required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//Reusable Input Field
Widget buildInputField({
  required String label,
  required String placeholder,
  required TextEditingController controller,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.cyanAccent[700],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white70),
              suffixIcon: suffixIcon ?? SizedBox(width: 0, height: 0),
              contentPadding: const EdgeInsets.only(bottom: 8),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
