import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:atmosfera/services/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post.dart';

class PostService {
  final String baseUrl = 'http://$BASE_URL/api/posts';
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Fetch all posts
  Future<List<Post>> fetchPosts() async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found! User may be logged out.");
        return [];
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("🔍 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.isEmpty) {
          print("No posts available in the response.");
          return [];
        }

        return jsonData.map((json) {
          print("Parsing Post JSON: $json");
          return Post.fromJson(json);
        }).toList();
      } else {
        print("Failed to load posts. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching posts: $error");
      return [];
    }
  }

  // Create a new post
  Future<bool> createPost({
    required String userId,
    required String caption,
    required String category,
    required String? location,
    required Map<String, dynamic>? locationData,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found! User may be logged out.");
        return false;
      }

      var request = http.MultipartRequest("POST", Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['user_id'] = userId;
      request.fields['caption'] = caption;
      request.fields['category'] = category;

      if (location != null && locationData != null) {
        request.fields['location'] = jsonEncode({
          "type": "Point",
          "coordinates": locationData["coordinates"],
          "address": locationData["address"],
        });
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', imageFile.path),
        );
      } else if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'media',
            webImage,
            filename: 'web_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      print("Sending Post Request...");
      print("Token: $token");
      print("Payload: ${request.fields}");

      var response = await request.send();
      if (response.statusCode == 201) {
        print("Post Created Successfully!");
        return true;
      } else {
        print("Post Creation Failed. Status Code: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      print("Error creating post: $error");
      return false;
    }
  }

  // Fetch posts for a specific user
  Future<List<Post>> fetchUserPosts(String userId) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found! User may be logged out.");
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.isEmpty) {
          print("No posts available for this user.");
          return [];
        }

        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        print("Failed to load user posts. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error fetching user posts: $error");
      return [];
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found! User may be logged out.");
        return false;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("🗑️ Delete Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Post deleted successfully");
        return true;
      } else {
        print("❌ Failed to delete post: ${response.body}");
        return false;
      }
    } catch (error) {
      print("🚨 Error deleting post: $error");
      return false;
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String caption,
    required String category,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    try {
      String? token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print("No token found! User may be logged out.");
        return false;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/$postId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['caption'] = caption;
      request.fields['category'] = category;

      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'media',
            webImage,
            filename: 'updated_web_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          imageFile.path,
        ));
      }

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print("✅ Post updated successfully!");
        return true;
      } else {
        print("❌ Failed to update post: ${result.body}");
        return false;
      }
    } catch (e) {
      print("Error updating post: $e");
      return false;
    }
  }
}
