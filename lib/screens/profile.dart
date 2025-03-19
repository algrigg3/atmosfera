import 'dart:convert';
import 'package:flutter/material.dart';
import 'theNow.dart';
import '../screens/editProfileScreen.dart';
import 'package:http/http.dart' as http;

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
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.70:5000/api/auth/profile/${widget.userId}'),
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
        title: const Text('Profile'),
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
              ? const Center(child: Text('❌ Failed to load profile.'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsTab(),
                    _buildBucketListTab(),
                  ],
                ),
    );
  }

  /// **Profile Header (WITHOUT Profile Picture)**
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(
              height: 20), // ✅ Placeholder for profile picture (kept blank)
          Text(
            username,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(bio, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(title: 'Posts', count: postsCount),
              _ProfileStat(title: 'Pins', count: pinsCount),
              _ProfileStat(title: 'Followers', count: followersCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        _buildProfileHeader(),
        const Expanded(child: Center(child: Text('User Posts Here'))),
      ],
    );
  }

  Widget _buildBucketListTab() {
    return Column(
      children: [
        _buildProfileHeader(),
        const Expanded(
            child: Center(child: Text('Bucket List (Pinned Posts)'))),
      ],
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
        Text('$count',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
