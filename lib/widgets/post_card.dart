import 'package:atmosfera/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String description;
  final String? location;
  final LatLng? locationCoords;
  final String? imageUrl;
  final String userId;
  final VoidCallback onPin;
  final VoidCallback? onLocationTap;
  final bool isPinned;
  final DateTime timestamp; // 👈 renamed for clarity
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    Key? key,
    required this.username,
    required this.description,
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
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600), // 👈 max width for desktop
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
                /// Username
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfilePage(userId: userId)),
                  ),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                /// Location
                if (location != null && locationCoords != null)
                  GestureDetector(
                    onTap: onLocationTap,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.blue, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location!,
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

                const SizedBox(height: 10),

                /// Image
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 4 / 3, // 👈 consistent ratio
                      child: Image.network(
                        imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      ),
                    ),
                  )
                else
                  _buildPlaceholderImage(),

                const SizedBox(height: 12),

                /// Caption
                Text(description, style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 8),

                /// Timestamp
                Text(
                  _formatTimeAgo(timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 10),

                /// Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onPin,
                      icon: Icon(Icons.push_pin,
                          color: isPinned ? Colors.blue : Colors.blue),
                      label: Text(
                        isPinned ? "Pinned" : "Pin",
                        style: TextStyle(
                            color: isPinned ? Colors.blue : Colors.blue),
                      ),
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) onEdit!();
                          if (value == 'delete' && onDelete != null)
                            onDelete!();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
