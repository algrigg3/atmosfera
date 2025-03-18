import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl =
      'http://192.168.1.70:5000/api/auth'; // Replace with actual backend URL
  final storage = const FlutterSecureStorage(); // Secure JWT storage

  // User Registration
  Future<Map<String, dynamic>> registerUser(
      String username, String email, String password, String phoneNumber,
      {String profilePicture = '', String bio = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'profile_picture': profilePicture,
          'bio': bio,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('Registration successful: ${data['message']}');
        return data;
      } else {
        print('Registration failed: ${data['message']}');
        return {'error': data['message'] ?? 'Registration failed'};
      }
    } catch (error) {
      print("Error during registration: $error");
      return {'error': 'An error occurred. Please try again later.'};
    }
  }

  // User Login
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await storage.write(
            key: 'jwt_token', value: data['token']); // Save JWT token
        await storage.write(
            key: 'user_id', value: data['userId']); // Save user ID
        print('Login successful: UserID: ${data['userId']}');
        return data;
      } else {
        print('Login failed: ${data['message']}');
        return {'error': data['message'] ?? 'Login failed'};
      }
    } catch (error) {
      print("Error during login: $error");
      return {'error': 'An error occurred. Please try again later.'};
    }
  }

  // Auto-login (Retrieve stored token)
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  // Logout User
  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'user_id');
    print("User logged out successfully");
  }
}
