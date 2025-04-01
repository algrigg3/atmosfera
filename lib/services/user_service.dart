import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:atmosfera/services/constants.dart';
import 'auth_service.dart';

class UserService {
  final String baseUrl = '$BASE_URL/api/users';

  Future<Map<String, dynamic>> getMyProfile() async {
    String? token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    String? token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updatePassword(
      String currentPassword, String newPassword) async {
    String? token = await AuthService().getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/update-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<void> deleteUser() async {
    String? token = await AuthService().getToken();

    await http.delete(
      Uri.parse('$baseUrl/delete'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    await AuthService().logout();
  }
}
