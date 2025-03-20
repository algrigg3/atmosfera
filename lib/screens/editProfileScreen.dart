import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:atmosfera/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String bio;
  final String email;
  final String phoneNumber;
  final Function(String, String, String, String) onProfileUpdated;

  const EditProfileScreen({
    Key? key,
    required this.userId,
    required this.username,
    required this.bio,
    required this.email,
    required this.phoneNumber,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool isUpdating = false;
  final String apiUrl =
      'http://192.168.1.70:5000/api/auth/update-profile'; // ✅ Define API URL

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _bioController.text = widget.bio;
    _emailController.text = widget.email;
    _phoneController.text = widget.phoneNumber;
  }

  void _handleLogout() async {
    AuthService authService = AuthService();
    await authService.logout(); // ✅ Call the logout function

    print("🔄 Navigating to home screen...");

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  /// 🚀 **Update Profile Information**
  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ All fields must be filled out.')),
      );
      return;
    }

    setState(() => isUpdating = true);

    AuthService authService = AuthService();
    String? token = await authService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Unauthorized: Please log in again.')),
      );
      setState(() => isUpdating = false);
      return;
    }

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "username": _usernameController.text.trim(),
        "bio": _bioController.text.trim(),
        "email": _emailController.text.trim(),
        "phone_number": _phoneController.text.trim(),
      }),
    );

    setState(() => isUpdating = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      widget.onProfileUpdated(
        data['username'],
        data['bio'],
        data['email'],
        data['phone_number'],
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to update profile: ${response.body}')),
      );
    }
  }

  /// 🔑 **Update Password**
  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Both fields are required.')),
      );
      return;
    }

    setState(() => isUpdating = true);

    AuthService authService = AuthService();
    bool success = await authService.updatePassword(
      _currentPasswordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => isUpdating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Password updated successfully!')),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '❌ Failed to update password. Please check your current password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 📌 **Username Field**
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),

              // 📌 **Bio Field**
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
              ),

              // 📌 **Email Field**
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              // 📌 **Phone Number Field**
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),

              const SizedBox(height: 20),

              // 📌 **Save Profile Button**
              ElevatedButton(
                onPressed: isUpdating ? null : _updateProfile,
                child: isUpdating
                    ? const CircularProgressIndicator()
                    : const Text("Save Changes"),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // 🔑 **Password Update Section**
              const Text(
                "Update Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // 📌 **Current Password Field**
              TextField(
                controller: _currentPasswordController,
                decoration:
                    const InputDecoration(labelText: "Current Password"),
                obscureText: true,
              ),

              // 📌 **New Password Field**
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: "New Password"),
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // 📌 **Update Password Button**
              ElevatedButton(
                onPressed: isUpdating ? null : _updatePassword,
                child: isUpdating
                    ? const CircularProgressIndicator()
                    : const Text("Update Password"),
              ),

              const SizedBox(height: 20),

              // 🚀 Logout Button
              ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
