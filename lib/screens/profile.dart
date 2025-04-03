import 'dart:convert';
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
  int postsCount = 0;
  int followersCount = 0;
  bool isOwnProfile = false;
  bool isFollowing = false;
  bool isLoading = true;
  bool hasError = false;
  bool isPinnedLoading = true;
  bool pinnedHasError = false;
  bool followLoading = false;
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
          pinnedPosts = data.map((json) => Post.fromJson(json)).toList();
          isPinnedLoading = false;
        });
      } else {
        setState(() => pinnedHasError = true);
      }
    } catch (e) {
      setState(() => pinnedHasError = true);
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

  void _handleDeletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('http://$BASE_URL/api/posts/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          userPostsFuture = PostService().fetchUserPosts(widget.userId);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Post deleted')));
      }
    }
  }

  void _handleEditPost(Post post) {
    // TODO: Navigate to edit screen
    print("Edit tapped for post: \${post.id}");
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Failed to load profile.'))
              : TabBarView(
                  controller: _tabController,
                  children: isOwnProfile
                      ? [_buildPostsTab(), _buildBucketListTab()]
                      : [_buildPostsTab()],
                ),
    );
  }

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
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(child: Text("No posts yet"));
              }
              final posts = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() => userPostsFuture =
                      PostService().fetchUserPosts(widget.userId));
                },
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      username: username,
                      description: post.caption,
                      location: post.address,
                      locationCoords: post.coordinates.isNotEmpty
                          ? LatLng(post.coordinates[1], post.coordinates[0])
                          : null,
                      imageUrl: post.media,
                      userId: widget.userId,
                      onPin: () {},
                      isPinned: false,
                      timestamp: post.createdAt,
                      isOwner: isOwnProfile,
                      onDelete: () => _handleDeletePost(post.id),
                      onEdit: () => _handleEditPost(post),
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
    final filtered = selectedCategory == 'All'
        ? pinnedPosts
        : pinnedPosts.where((p) => p.category == selectedCategory).toList();
    return Column(
      children: [
        _buildProfileHeader(),
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
                                username: post.username,
                                description: post.caption,
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
                                isOwner: false,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(username,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(bio, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          if (!isOwnProfile)
            ElevatedButton(
              onPressed: followLoading ? null : _toggleFollow,
              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(title: 'Posts', count: postsCount),
              _ProfileStat(title: 'Followers', count: followersCount),
            ],
          )
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final int count;

  const _ProfileStat({required this.title, required this.count});

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
