import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/locationScreen.dart';
import '../widgets/tabBar.dart';
import '../widgets/post_card.dart';
import '../services/post_service.dart';
import '../models/post.dart';

class TheNow extends StatefulWidget {
  final String userId;

  const TheNow({Key? key, required this.userId}) : super(key: key);

  @override
  _TheNowState createState() => _TheNowState();
}

class _TheNowState extends State<TheNow> {
  final PostService postService = PostService();
  late Future<List<Post>> postsFuture;
  Set<String> pinnedPosts = {}; //  Track pinned post IDs

  @override
  void initState() {
    super.initState();
    postsFuture = postService.fetchPosts();
    fetchPinnedPosts(); // Fetch pinned posts when the screen loads
  }

  // Fetch pinned posts from the backend
  Future<void> fetchPinnedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.70:5000/api/bucket-list/bucket-list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> pinnedData = jsonDecode(response.body);
      setState(() {
        pinnedPosts =
            pinnedData.map((post) => post['postId'] as String).toSet();
      });
    } else {
      print(" Failed to fetch pinned posts");
    }
  }

  Future<void> togglePin(String postId) async {
    try {
      final authService = AuthService();
      String? token =
          await authService.getToken(); // Ensure we retrieve the token

      print("🔍 Token Before Pin Request: $token"); //  Debugging

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Please log in to pin posts.')),
        );
        return;
      }

      bool isCurrentlyPinned = pinnedPosts.contains(postId);
      String url = isCurrentlyPinned
          ? 'http://192.168.1.70:5000/api/bucket-list/unpin/$postId' //  Unpin if already pinned
          : 'http://192.168.1.70:5000/api/bucket-list/pin/$postId';

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print("📡 Sending Request to: $url"); //  Debugging
      print("📡 Headers: $headers"); // Debugging

      final response = isCurrentlyPinned
          ? await http.delete(Uri.parse(url),
              headers: headers) //  Unpin request
          : await http.post(Uri.parse(url),
              headers: headers,
              body: jsonEncode({'category': 'general'})); //  Pin request

      print("🔄 Response Status Code: ${response.statusCode}"); // Debugging
      print("🔄 Response Body: ${response.body}"); //  Debugging

      if (response.statusCode == 200) {
        setState(() {
          if (isCurrentlyPinned) {
            pinnedPosts.remove(postId); // Remove from pinned list
          } else {
            pinnedPosts.add(postId); //  Add to pinned list
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isCurrentlyPinned ? 'Post unpinned!' : ' Post pinned!'),
          ),
        );
      } else {
        print(" Server Response: ${response.body}"); //  Debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update pin status.')),
        );
      }
    } catch (e) {
      print(" Error in togglePin(): $e");
    }
  }

  //  Refresh Posts
  Future<void> _refreshPosts() async {
    setState(() {
      postsFuture = postService.fetchPosts();
    });
    fetchPinnedPosts(); //  Also refresh pinned posts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Tab Bar
          CustomTabBar(currentTab: "The Now", currentUserId: widget.userId),

          // Post Feed
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(" Error loading posts"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No posts available"));
                }

                List<Post> posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      Post post = posts[index];

                      return PostCard(
                        username: post.username,
                        description: post.caption,
                        location: post.address,
                        locationCoords: post.coordinates.isNotEmpty
                            ? LatLng(post.coordinates[1], post.coordinates[0])
                            : null,
                        imageUrl: post.media,
                        userId: widget.userId,
                        onPin: () => togglePin(post.id),
                        onLocationTap: () {
                          if (post.coordinates.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationDetailScreen(
                                  username: post.username,
                                  locationName: post.address,
                                  locationCoords: LatLng(
                                      post.coordinates[1], post.coordinates[0]),
                                  address: post.address,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          }
                        }, // Navigate to location
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
