import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PostService {
  final String baseUrl = 'http://192.168.1.70/api/posts';

  Future<List<dynamic>> fetchPosts() async {
    String? token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch posts');
    }
  }
}
