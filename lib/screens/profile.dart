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
  bool isLoading = true;
  bool hasError = false;
  late Future<List<Post>> userPostsFuture; //  Fetch user’s posts
  late String currentUserId;
  bool isOwnProfile = false;
  bool isFollowing = false;
  bool followLoading = false;

  // User profile data
  String username = "Loading...";
  String bio = "Loading...";
  String email = "No email provided";
  String phoneNumber = "No phone number provided";
  int postsCount = 0;
  int pinsCount = 0;
  int followersCount = 0;
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
  bool isPinnedLoading = true;
  bool pinnedHasError = false;

  @override
  void initState() {
    super.initState();

    AuthService().getUserId().then((id) {
      setState(() {
        currentUserId = id!;
        isOwnProfile = id == widget.userId;

        // ✅ Initialize the tab controller with correct length
        _tabController =
            TabController(length: isOwnProfile ? 2 : 1, vsync: this);

        if (!isOwnProfile) {
          _checkFollowingStatus();
        }
      });

      _loadUserProfile();
      userPostsFuture = PostService().fetchUserPosts(widget.userId);
      fetchPinnedPosts();
    });
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      _loadUserProfile();
      userPostsFuture = PostService().fetchUserPosts(widget.userId);
      fetchPinnedPosts();

      AuthService().getUserId().then((id) {
        setState(() {
          currentUserId = id!;
          isOwnProfile = id == widget.userId;

          // ✅ Recreate TabController
          _tabController.dispose();
          _tabController =
              TabController(length: isOwnProfile ? 2 : 1, vsync: this);

          if (!isOwnProfile) _checkFollowingStatus();
        });
      });
    }
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
        setState(() {
          isFollowing = data['isFollowing'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => followLoading = true);
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        print('❌ No token found');
        return;
      }

      print('🔁 Toggling follow for user: ${widget.userId}');

      final response = await http.post(
        Uri.parse('http://$BASE_URL/api/users/${widget.userId}/follow'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📬 Status Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isFollowing = data['following'];
          // followerCount is updated fresh in _loadUserProfile
        });

        // Refresh the full profile (including followers count)
        await _loadUserProfile();
      } else {
        print('⚠️ Failed to toggle follow: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error toggling follow: $e');
    } finally {
      setState(() => followLoading = false);
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
        final body = response.body;

        if (body.isNotEmpty) {
          final List<dynamic> data = jsonDecode(body);

          setState(() {
            pinnedPosts = data
                .where((json) => json != null)
                .map((json) => Post.fromJson(json))
                .toList();
            isPinnedLoading = false;
          });
        } else {
          print('⚠️ Empty body received for pinned posts');
          setState(() {
            pinnedPosts = [];
            isPinnedLoading = false;
          });
        }
      } else {
        print('⚠️ Failed to fetch pinned posts: ${response.body}');
        setState(() {
          pinnedHasError = true;
          isPinnedLoading = false;
        });
      }
    } catch (e) {
      print('🔥 Error fetching pinned posts: $e');
      setState(() {
        pinnedHasError = true;
        isPinnedLoading = false;
      });
    }
  }

  Future<void> togglePin(String postId) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('http://$BASE_URL/api/bucket-list/unpin/$postId'),
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
        print('Failed to unpin: ${response.body}');
      }
    } catch (e) {
      print('Error in togglePin: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await AuthService().getToken();
      print('🔑 Got token: $token');
      print('👤 Loading profile for user ID: ${widget.userId}');

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
          bio = profileData['bio'] ?? "No bio available";
          email = profileData['email'] ?? "No email provided";
          phoneNumber =
              profileData['phone_number'] ?? "No phone number provided";
          followersCount = statsData['followerCount'] ?? 0;
          postsCount = statsData['postCount'] ?? 0;
          isLoading = false;
        });
      } else {
        print('❌ Error: One or both requests failed');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('🔥 Exception in _loadUserProfile: $e');
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
                builder: (context) => TheNow(userId: currentUserId),
              ),
            );
          },
        ),
        title: Text(username),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          userId: currentUserId,
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
                        print("Post pinned by ${post.username}!");
                      },
                      isPinned: false,
                      timestamp: post.createdAt,
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
    List<Post> filteredPosts = selectedCategory == 'All'
        ? pinnedPosts
        : pinnedPosts
            .where((post) => post.category == selectedCategory)
            .toList();

    return Column(
      children: [
        _buildProfileHeader(),

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

        // Pinned posts list
        Expanded(
          child: isPinnedLoading
              ? const Center(child: CircularProgressIndicator())
              : pinnedHasError
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
          if (!isOwnProfile)
            ElevatedButton(
              onPressed: followLoading ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
              ),
              child: Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(
                  color: isFollowing ? Colors.black : Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(title: 'Posts', count: postsCount),
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
