import 'package:atmosfera/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/constants.dart';
import '../services/auth_service.dart';

class PostCard extends StatefulWidget {
  final String postId;
  final String username;
  final String description;
  final String caption;
  final String? location;
  final LatLng? locationCoords;
  final String? imageUrl;
  final String userId;
  final VoidCallback onPin;
  final VoidCallback? onLocationTap;
  final bool isPinned;
  final DateTime timestamp;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    Key? key,
    required this.postId,
    required this.username,
    required this.description,
    required this.caption,
    this.location,
    this.locationCoords,
    this.imageUrl,
    required this.userId,
    required this.onPin,
    this.onLocationTap,
    required this.isPinned,
    required this.timestamp,
    required this.isOwner,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  List comments = [];
  final TextEditingController _commentController = TextEditingController();

  Future<void> fetchComments() async {
    final res = await http
        .get(Uri.parse('http://$BASE_URL/api/comments/${widget.postId}'));
    if (res.statusCode == 200) {
      setState(() {
        comments = json.decode(res.body);
      });
    }
  }

  Future<void> addComment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) {
      print('❌ Empty comment');
      return;
    }

    final authService = AuthService(); // ✅ use the service
    final token = await authService.getToken();

    if (token == null) {
      print('❌ No token found');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('http://$BASE_URL/api/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'postId': widget.postId,
          'comment': content,
        }),
      );

      print('📤 Add Comment Response: ${res.statusCode}');
      print('📤 Body: ${res.body}');

      if (res.statusCode == 201) {
        _commentController.clear();
        fetchComments(); // 👈 refresh comments
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment.')),
        );
      }
    } catch (e) {
      print('🚨 Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildImage(),
                const SizedBox(height: 12),
                Text(widget.description, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  _formatTimeAgo(widget.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                _buildActions(context),
                if (showComments) _buildCommentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProfilePage(userId: widget.userId)),
          ),
          child: Text(
            widget.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.location != null && widget.locationCoords != null)
          GestureDetector(
            onTap: widget.onLocationTap,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.location!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.network(
            widget.imageUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
          ),
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: widget.onPin,
          icon: Icon(Icons.push_pin,
              color: widget.isPinned ? Colors.blue : Colors.blue),
          label: Text(
            widget.isPinned ? "Pinned" : "Pin",
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(showComments ? Icons.comment_bank : Icons.comment),
              onPressed: () {
                setState(() => showComments = !showComments);
                if (!comments.isNotEmpty) fetchComments();
              },
            ),
            if (widget.isOwner)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && widget.onEdit != null)
                    widget.onEdit!();
                  if (value == 'delete' && widget.onDelete != null)
                    widget.onDelete!();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        ...comments.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['userId']['username'] ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(c['comment']),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Add a comment...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: addComment,
            )
          ],
        )
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }
}
