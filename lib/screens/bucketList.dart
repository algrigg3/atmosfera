import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../services/auth_service.dart';
import '../widgets/post_card.dart';
import '../widgets/tabBar.dart';

class BucketList extends StatefulWidget {
  final String userId;

  const BucketList({Key? key, required this.userId}) : super(key: key);

  @override
  _BucketListState createState() => _BucketListState();
}

class _BucketListState extends State<BucketList> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars',
  ];

  List<Post> pinnedPosts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPinnedPosts();
  }

  Future<void> fetchPinnedPosts() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://192.168.1.70:5000/api/bucket-list/bucket-list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pinnedPosts = data.map((json) => Post.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching pinned posts: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> togglePin(String postId) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('http://192.168.1.70:5000/api/bucket-list/unpin/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await fetchPinnedPosts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post unpinned.')),
        );
      } else {
        print('❌ Failed to unpin: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in togglePin: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Post> filteredPosts = selectedCategory == 'All'
        ? pinnedPosts
        : pinnedPosts
            .where((post) => post.category == selectedCategory)
            .toList();

    return Scaffold(
      body: Column(
        children: [
          // Custom Tab Bar
          CustomTabBar(currentTab: "Bucket List", currentUserId: widget.userId),

          // Dropdown filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Category: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List of filtered pinned posts
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(child: Text('Failed to load pinned posts.'))
                    : RefreshIndicator(
                        onRefresh: fetchPinnedPosts,
                        child: filteredPosts.isEmpty
                            ? const Center(child: Text('No pinned posts yet.'))
                            : ListView.builder(
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];
                                  return PostCard(
                                    username: post.username,
                                    description: post.caption,
                                    location: post.address,
                                    locationCoords: post.coordinates.isNotEmpty
                                        ? LatLng(post.coordinates[1],
                                            post.coordinates[0])
                                        : null,
                                    imageUrl: post.media,
                                    userId: widget.userId,
                                    isPinned: true,
                                    timestamp: post.createdAt,
                                    onPin: () => togglePin(post.id),
                                    onLocationTap: () {
                                      // Optional: open location screen
                                    },
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}
