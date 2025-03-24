import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../widgets/post_card.dart';
import 'theNow.dart';
import '../screens/editProfileScreen.dart';
import '../services/post_service.dart';
import '../models/post.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  bool hasError = false;
  late Future<List<Post>> userPostsFuture; //  Fetch user’s posts

  // User profile data
  String username = "Loading...";
  String bio = "Loading...";
  String email = "No email provided";
  String phoneNumber = "No phone number provided";
  int postsCount = 0;
  int pinsCount = 0;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
    userPostsFuture =
        PostService().fetchUserPosts(widget.userId); //  Fetch user posts
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/auth/profile/${widget.userId}'),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          username = data['username'] ?? "Unknown";
          bio = data['bio'] ?? "No bio available";
          email = data['email'] ?? "No email provided";
          phoneNumber = data['phone_number'] ?? "No phone number provided";
          followersCount =
              (data['followers'] is List) ? data['followers'].length : 0;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching profile: $error");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TheNow(userId: widget.userId),
              ),
            );
          },
        ),
        title: Text(username),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userId: widget.userId,
                    username: username,
                    bio: bio,
                    email: email,
                    phoneNumber: phoneNumber,
                    onProfileUpdated:
                        (newUsername, newBio, newEmail, newPhone) {
                      setState(() {
                        username = newUsername;
                        bio = newBio;
                        email = newEmail;
                        phoneNumber = newPhone;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Bucket List'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text(' Failed to load profile.'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsTab(), //  Display user’s posts
                    _buildBucketListTab(),
                  ],
                ),
    );
  }

  /// ** Modify `_buildPostsTab()` to Show User's Posts**
  Widget _buildPostsTab() {
    return Column(
      children: [
        _buildProfileHeader(),
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: userPostsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text(" Error loading posts"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No posts yet"));
              }

              List<Post> userPosts = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    userPostsFuture =
                        PostService().fetchUserPosts(widget.userId);
                  });
                },
                child: ListView.builder(
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    Post post = userPosts[index];

                    return PostCard(
                      username: username,
                      description: post.caption,
                      location: post.address,
                      locationCoords: post.coordinates.isNotEmpty
                          ? LatLng(post.coordinates[1], post.coordinates[0])
                          : null,
                      imageUrl: post.media,
                      userId: widget.userId,
                      onPin: () {
                        print(" Post pinned by ${post.username}!");
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBucketListTab() {
    return Column(
      children: [
        _buildProfileHeader(),
        const Expanded(
          child: Center(child: Text('Bucket List (Pinned Posts)')),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(bio, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(
                  title: 'Posts',
                  count: 0), //  Update later with real post count
              _ProfileStat(title: 'Followers', count: followersCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final int count;

  const _ProfileStat({Key? key, required this.title, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
