import 'dart:convert';
import 'package:atmosfera/screens/editpostScreen.dart';
import 'package:atmosfera/services/auth_service.dart';
import 'package:atmosfera/services/constants.dart';
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
  late String currentUserId;
  late Future<List<Post>> userPostsFuture;
  List<Post> pinnedPosts = [];
  String username = "Loading...";
  String bio = "Loading...";
  String email = "No email provided";
  String phoneNumber = "No phone number provided";
  String profilePictureUrl = "";
  int postsCount = 0;
  int followersCount = 0;
  bool isOwnProfile = false;
  bool isFollowing = false;
  bool isLoading = true;
  bool hasError = false;
  bool isPinnedLoading = true;
  bool pinnedHasError = false;
  bool followLoading = false;
  bool isTabReady = false;
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars'
  ];

  @override
  void initState() {
    super.initState();
    AuthService().getUserId().then((id) {
      currentUserId = id!;
      isOwnProfile = currentUserId == widget.userId;
      _tabController = TabController(length: isOwnProfile ? 2 : 1, vsync: this);
      setState(() => isTabReady = true);
      if (!isOwnProfile) _checkFollowingStatus();
      _loadUserProfile();
      userPostsFuture = PostService().fetchUserPosts(widget.userId);
      fetchPinnedPosts();
    });
  }

  Future<void> _checkFollowingStatus() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://$BASE_URL/api/users/${widget.userId}/is-following'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isFollowing = data['isFollowing'] ?? false);
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => followLoading = true);
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('http://$BASE_URL/api/users/${widget.userId}/follow'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => isFollowing = data['following']);
        await _loadUserProfile();
      }
    } catch (e) {
      print('Error toggling follow: $e');
    } finally {
      setState(() => followLoading = false);
    }
  }

  Future<void> togglePin(String postId) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('http://$BASE_URL/api/bucket-list/unpin/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await fetchPinnedPosts();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Post unpinned.')));
      }
    } catch (e) {
      print('Error in togglePin: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await AuthService().getToken();
      final profileRes = await http.get(
        Uri.parse('http://$BASE_URL/api/auth/profile/${widget.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final statsRes = await http.get(
        Uri.parse('http://$BASE_URL/api/users/${widget.userId}/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (profileRes.statusCode == 200 && statsRes.statusCode == 200) {
        final profileData = jsonDecode(profileRes.body);
        final statsData = jsonDecode(statsRes.body);
        setState(() {
          username = profileData['username'] ?? "Unknown";
          bio = profileData['bio'] ?? "";
          email = profileData['email'] ?? "";
          phoneNumber = profileData['phone_number'] ?? "";
          profilePictureUrl = profileData['profile_picture'] ?? "";
          followersCount = statsData['followerCount'] ?? 0;
          postsCount = statsData['postCount'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }

  Future<void> fetchPinnedPosts() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('http://$BASE_URL/api/bucket-list/bucket-list'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pinnedPosts = data
              .map((json) => Post.fromJson(json))
              .toList()
              .reversed
              .toList();
          isPinnedLoading = false;
        });
      } else {
        setState(() {
          pinnedHasError = true;
          isPinnedLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        pinnedHasError = true;
        isPinnedLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isTabReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TheNow(userId: currentUserId)),
          ),
        ),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        userId: currentUserId,
                        username: username,
                        bio: bio,
                        email: email,
                        phoneNumber: phoneNumber,
                        onProfileUpdated: (u, b, e, p) => setState(() {
                          username = u;
                          bio = b;
                          email = e;
                          phoneNumber = p;
                        }),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
        bottom: TabBar(
          controller: _tabController,
          tabs: isOwnProfile
              ? const [Tab(text: 'Posts'), Tab(text: 'Bucket List')]
              : const [Tab(text: 'Posts')],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: 220,
            color: Colors.blue[900],
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (!isOwnProfile)
                  ElevatedButton(
                    onPressed: followLoading ? null : _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[900],
                    ),
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                  ),
                const SizedBox(height: 16),
                _ProfileStat(
                    title: 'Posts', count: postsCount, color: Colors.white),
                const SizedBox(height: 8),
                _ProfileStat(
                    title: 'Followers',
                    count: followersCount,
                    color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: isOwnProfile
                  ? [_buildPostsTab(), _buildBucketListTab()]
                  : [_buildPostsTab()],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Post>>(
      future: userPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No posts yet"));
        }
        final posts = snapshot.data!.reversed.toList();
        return RefreshIndicator(
          onRefresh: () async {
            setState(() =>
                userPostsFuture = PostService().fetchUserPosts(widget.userId));
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                  postId: post.id,
                  username: username,
                  description: post.caption,
                  caption: post.caption,
                  location: post.address,
                  locationCoords: post.coordinates.isNotEmpty
                      ? LatLng(post.coordinates[1], post.coordinates[0])
                      : null,
                  imageUrl: post.media,
                  onPin: () => togglePin(post.id),
                  userId: widget.userId,
                  isPinned: false,
                  isOwner: isOwnProfile,
                  timestamp: post.createdAt,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPostScreen(
                          post: post, // ✅ this passes the entire Post object
                          onUpdated: () {
                            setState(() {
                              userPostsFuture = PostService()
                                  .fetchUserPosts(widget.userId); // refresh
                            });
                          },
                        ),
                      ),
                    );
                  });
            },
          ),
        );
      },
    );
  }

  Widget _buildBucketListTab() {
    final filtered = selectedCategory == 'All'
        ? pinnedPosts.reversed.toList()
        : pinnedPosts
            .where((p) => p.category == selectedCategory)
            .toList()
            .reversed
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButton<String>(
            value: selectedCategory,
            onChanged: (val) => setState(() => selectedCategory = val!),
            items: categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
          ),
        ),
        Expanded(
          child: isPinnedLoading
              ? const Center(child: CircularProgressIndicator())
              : pinnedHasError
                  ? const Center(child: Text('Failed to load pinned posts.'))
                  : filtered.isEmpty
                      ? const Center(child: Text('No pinned posts yet.'))
                      : RefreshIndicator(
                          onRefresh: fetchPinnedPosts,
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final post = filtered[index];
                              return PostCard(
                                postId: post.id,
                                username: post.username,
                                description: post.caption,
                                caption: post.caption,
                                location: post.address,
                                locationCoords: post.coordinates.isNotEmpty
                                    ? LatLng(post.coordinates[1],
                                        post.coordinates[0])
                                    : null,
                                imageUrl: post.media,
                                userId: widget.userId,
                                onPin: () => togglePin(post.id),
                                isPinned: true,
                                timestamp: post.createdAt,
                                isOwner: widget.userId == post.userId,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _ProfileStat({
    required this.title,
    required this.count,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          title,
          style: TextStyle(color: color.withOpacity(0.7)),
        ),
      ],
    );
  }
}
