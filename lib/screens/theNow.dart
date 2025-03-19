import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    postsFuture = postService.fetchPosts();
  }

  // Function to Refresh Posts
  Future<void> _refreshPosts() async {
    setState(() {
      postsFuture = postService.fetchPosts();
    });
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
                // Show Loading Spinner while fetching
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle Errors
                if (snapshot.hasError) {
                  return Center(child: Text("❌ Error loading posts"));
                }

                // If no posts, show a message
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No posts available"));
                }

                // Display Posts
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
                        onPin: () {
                          print("📌 Post pinned by ${post.username}!");
                        },
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
