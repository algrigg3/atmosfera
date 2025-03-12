import 'package:flutter/material.dart';
import 'theNow.dart';

// Mock user data (replace with API call later)
final Map<String, dynamic> mockUsers = {
  "mock_user_id_456": {
    "username": "skyWood12",
    "bio": "Adventurer. Coder. Explorer of new places.",
    "profilePic": "https://via.placeholder.com/150",
    "postsCount": 12,
    "pinsCount": 5,
    "followersCount": 250,
  },
  "mock_user_id_123": {
    "username": "NatCarroll45",
    "bio": "Love traveling & meeting new people.",
    "profilePic": "https://via.placeholder.com/150",
    "postsCount": 8,
    "pinsCount": 3,
    "followersCount": 180,
  },
};

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ User profile data variables
  String username = "Loading...";
  String bio = "Loading...";
  String profilePic = "https://via.placeholder.com/150";
  int postsCount = 0;
  int pinsCount = 0;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile(); // ✅ Load user data based on userId
  }

  void _loadUserProfile() {
    final userData = mockUsers[widget.userId];

    if (userData != null) {
      setState(() {
        username = userData["username"];
        bio = userData["bio"];
        profilePic = userData["profilePic"];
        postsCount = userData["postsCount"];
        pinsCount = userData["pinsCount"];
        followersCount = userData["followersCount"];
      });
    } else {
      print("⚠️ User not found!");
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
            // ✅ Go back to TheNow and pass userId!
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TheNow(userId: widget.userId)),
            );
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings feature coming soon!')),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(), // User's posts
          _buildBucketListTab() // User's pinned posts
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profilePic),
          ),
          const SizedBox(height: 8),
          Text(username,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(bio, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(title: 'Posts', count: postsCount),
              _ProfileStat(title: 'Pins', count: pinsCount),
              _ProfileStat(title: 'Followers', count: followersCount),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        _buildProfileHeader(),
        const Expanded(
          child: Center(child: Text('User Posts Here')),
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
