import 'dart:convert';
import 'package:atmosfera/services/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://$BASE_URL/api/auth';
  final storage = const FlutterSecureStorage(); //Secure JWT storage

  //User Registration
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
        print(' Registration successful: ${data['message']}');
        return data;
      } else {
        print(' Registration failed: ${data['message']}');
        return {'error': data['message'] ?? 'Registration failed'};
      }
    } catch (error) {
      print(" Error during registration: $error");
      return {'error': 'An error occurred. Please try again later.'};
    }
  }

  //User Login
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
            key: 'jwt_token', value: data['token']); //Save JWT token
        await storage.write(
            key: 'user_id', value: data['userId']); //Save user ID
        print(' Login successful: UserID: ${data['userId']}');
        return data;
      } else {
        print(' Login failed: ${data['message']}');
        return {'error': data['message'] ?? 'Login failed'};
      }
    } catch (error) {
      print(" Error during login: $error");
      return {'error': 'An error occurred. Please try again later.'};
    }
  }

  //Retrieve stored token
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  //Retrieve stored user ID
  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<void> logout() async {
    try {
      print(" Logging out: Attempting to retrieve token...");
      String? token = await getToken(); //Debugging check

      if (token == null) {
        print(" No token found! The user might already be logged out.");
      } else {
        print(" Retrieved Token Before Logout: $token");

        //Send logout request to backend
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          print(" Successfully logged out from backend.");
        } else {
          print(" Backend logout failed: ${response.body}");
        }
      }

      //Ensure token is deleted
      await storage.delete(key: 'jwt_token');
      await storage.delete(key: 'user_id');

      String? checkToken = await getToken(); //Check if token is really deleted
      print(" Token After Logout: $checkToken (Should be null)");

      print(" User logged out successfully.");
    } catch (e) {
      print(" Error during logout: $e");
    }
  }

  //Fetch user profile
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    String? token = await getToken();
    String? userId = await getUserId();

    if (token == null || userId == null) {
      print(" No token or user ID found. Please log in again.");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(' Error fetching profile: ${response.body}');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    String? token = await getToken();
    if (token == null) {
      print(" No token found. User may be logged out.");
      return false;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      print(" Profile updated successfully!");
      return true;
    } else {
      print(' Error updating profile: ${response.body}');
      return false;
    }
  }

  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    AuthService authService = AuthService();
    String? token = await authService.getToken(); // Retrieve token securely

    if (token == null) {
      print(" No token found. User may be logged out.");
      return false;
    }

    print(" Sending PUT request to update password...");
    print(" Current Password: $currentPassword");
    print(" New Password: $newPassword");

    final response = await http.put(
      Uri.parse('$baseUrl/update-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      }),
    );

    print(" Update Password Response Code: ${response.statusCode}");
    print(" Update Password Response Body: ${response.body}");

    if (response.statusCode == 200) {
      print(" Password updated successfully!");
      return true;
    } else {
      print(" Failed to update password: ${response.body}");
      return false;
    }
  }
}
