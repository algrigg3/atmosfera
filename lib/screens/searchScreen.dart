import 'package:atmosfera/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/tabBar.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  final String userId;
  const SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchType = 'Username';
  String searchQuery = '';
  List<Post> searchResults = [];
  bool isLoading = false;

  Future<void> performSearch() async {
    if (searchQuery.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      searchResults = [];
    });

    final uri = Uri.parse(
        'http://$BASE_URL/api/search?type=$searchType&query=$searchQuery');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final posts = data.map((json) => Post.fromJson(json)).toList();
        setState(() {
          searchResults = posts.cast<Post>();
        });
      } else {
        print('Search failed: ${response.body}');
      }
    } catch (e) {
      print('Error during search: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  final List<String> searchOptions = ['Username', 'Location', 'Category'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Tab Bar at the top
          CustomTabBar(currentTab: "Search", currentUserId: widget.userId),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search controls
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: searchType,
                        items: searchOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => searchType = val!);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter search...',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (val) => searchQuery = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: performSearch,
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search results
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.isEmpty
                            ? const Center(child: Text("No results"))
                            : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final post = searchResults[index];
                                  return PostCard(
                                    username: post.username,
                                    description: post.caption,
                                    location: post.address,
                                    locationCoords: post.coordinates.isNotEmpty
                                        ? LatLng(post.coordinates[1],
                                            post.coordinates[0])
                                        : null,
                                    imageUrl: post.media,
                                    userId: post.userId,
                                    isPinned: false,
                                    timestamp: post.createdAt,
                                    onPin: () {},
                                    onLocationTap: () {
                                      // Add navigation to location screen if needed
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
