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
  final VoidCallback? onLocationTap; //  New callback for location tap

  const PostCard({
    Key? key,
    required this.username,
    required this.description,
    this.location,
    this.locationCoords,
    this.imageUrl,
    required this.userId,
    required this.onPin,
    this.onLocationTap, //  Accept location tap callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Username
            Text(
              username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),

            //  Location (if available, with tap feature)
            if (location != null && locationCoords != null)
              GestureDetector(
                onTap: onLocationTap, //  Navigate when tapped
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration
                              .underline, // ✅ Indicate interactivity
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            //  Image (if available)
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                ),
              )
            else
              _buildPlaceholderImage(),

            const SizedBox(height: 10),

            //  Description
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),

            //  Pin Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onPin,
                  icon: const Icon(Icons.push_pin, color: Colors.blue),
                  label:
                      const Text("Pin", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //  Placeholder Image if no image is available
  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }
}
