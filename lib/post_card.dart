import 'locationScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String? location; // Optional
  final LatLng? locationCoords;
  final String? address; // Optional address for display
  final String? imageUrl; // Optional
  final String description;
  final String userId;

  final VoidCallback onPin;
  final VoidCallback onComment;

  const PostCard({
    Key? key,
    required this.username,
    this.location,
    this.locationCoords,
    this.address,
    this.imageUrl,
    required this.description,
    required this.userId,
    required this.onPin, // ✅ Required callback
    required this.onComment, // ✅ Required callback
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isPinned = false; // ✅ Track local pinned state

  void _togglePin() {
    setState(() {
      isPinned = !isPinned;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Username and optional location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (widget.location != null)
                  GestureDetector(
                    onTap: () {
                      print("Location tapped!"); // Debug
                      if (widget.locationCoords != null &&
                          widget.address != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationDetailScreen(
                              username: widget.username,
                              locationName: widget.location!,
                              locationCoords: widget.locationCoords!,
                              address: widget.address!,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      } else {
                        print(
                            "⚠️ Missing data: locationCoords or address is null!");
                      }
                    },
                    child: Text(
                      '@${widget.location}',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
              ],
            ),
            SizedBox(height: 10),

            // ✅ Optional Image
            if (widget.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
            ],

            // ✅ Comment & Pin icons row
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.comment_outlined),
                  onPressed: widget.onComment, // ✅ Call the passed function
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? Colors.blue : null,
                  ),
                  onPressed: () {
                    widget.onPin(); // ✅ Call external function
                    _togglePin(); // ✅ Update local pin state to reflect in UI
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Post description
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            // ✅ View Comments Link
            GestureDetector(
              onTap: widget.onComment, // ✅ Use the same comment function
              child: Text(
                'View Comments',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
