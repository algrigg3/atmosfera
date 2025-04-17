import 'package:flutter/material.dart';
import '../models/post.dart';

class BucketListCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTapSeeTheNow;
  final VoidCallback onUnpin;

  const BucketListCard({
    Key? key,
    required this.post,
    required this.onTapSeeTheNow,
    required this.onUnpin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Left: Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${post.address ?? "Unknown location"}',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'posted by ${post.username}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onTapSeeTheNow,
                      child: const Text(
                        'See The Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onUnpin,
                      child: const Icon(
                        Icons.push_pin,
                        size: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right: Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (post.media != null && post.media!.isNotEmpty)
                ? Image.network(
                    post.media!,
                    width: 75,
                    height: 55,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 75,
                    height: 55,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
        ],
      ),
    );
  }
}
