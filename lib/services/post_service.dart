import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post.dart'; // ✅ Import the Post model

class PostService {
  final String baseUrl = 'http://192.168.1.70:5000/api/posts';
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Secure token storage

  // **✅ Fetch all posts from the backend**
  Future<List<Post>> fetchPosts() async {
    try {
      String? token = await storage.read(key: 'jwt_token'); // ✅ Get JWT token
      if (token == null) {
        print("❌ No token found! User may be logged out.");
        return [];
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'}, // ✅ Attach token
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        print("❌ Failed to load posts. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("❌ Error fetching posts: $error");
      return [];
    }
  }

  // **✅ Create a new post**
  Future<bool> createPost({
    required String userId,
    required String caption,
    required String category,
    required String? location,
    File? imageFile, // ✅ Image is optional
  }) async {
    try {
      String? token = await storage.read(key: 'jwt_token'); // ✅ Get JWT token
      if (token == null) {
        print("❌ No token found! User may be logged out.");
        return false;
      }

      var request = http.MultipartRequest("POST", Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // ✅ Attach text fields
      request.fields['user_id'] = userId;
      request.fields['caption'] = caption;
      request.fields['category'] = category;

      // ✅ Send location correctly
      if (location != null) {
        request.fields['location'] = jsonEncode({
          "latitude": 37.7749, // Replace with actual latitude
          "longitude": -122.4194, // Replace with actual longitude
          "address": location,
        });
      }

      // ✅ Attach image ONLY IF user selected one
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', imageFile.path),
        );
      }

      print("🔍 Sending Post Request...");
      print("🔑 Token: $token");
      print("📦 Payload: ${request.fields}");

      var response = await request.send();
      if (response.statusCode == 201) {
        print("✅ Post Created Successfully!");
        return true;
      } else {
        print("❌ Post Creation Failed. Status Code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("❌ Error creating post: $error");
      return false;
    }
  }
}
