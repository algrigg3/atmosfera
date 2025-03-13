import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/locationScreen.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String? location;
  final LatLng? locationCoords;
  final String? address;
  final String? imageUrl;
  final String description;
  final String userId;
  final VoidCallback onPin;

  const PostCard({
    Key? key,
    required this.username,
    this.location,
    this.locationCoords,
    this.address,
    this.imageUrl,
    required this.description,
    required this.userId,
    required this.onPin,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isPinned = false;
  bool showComments = false;
  List<String> comments = [
    "Looks awesome!",
    "Wish I was there!",
    "Who's coming with me next time?"
  ];
  final TextEditingController _commentController = TextEditingController();

  void _togglePin() {
    setState(() {
      isPinned = !isPinned;
    });
  }

  void _toggleComments() {
    setState(() {
      showComments = !showComments;
    });
  }

  void _addComment() {
    String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      setState(() {
        comments.add(comment);
      });
      _commentController.clear();

      // TODO: Send comment to backend API here
      print("New comment added: $comment");
    }
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
            //Username and optional location
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

            //Optional Image
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

            //Like, Comment, Pin icons row
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.comment_outlined),
                  onPressed: _toggleComments,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isPinned ? Colors.blue : null,
                  ),
                  onPressed: () {
                    widget.onPin();
                    _togglePin();
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            //Post description
            Text(
              widget.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            //View Comments Link
            GestureDetector(
              onTap: _toggleComments,
              child: Text(
                showComments ? 'Hide Comments' : 'View Comments',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 10),

            //Comments Section (if expanded)
            if (showComments) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments
                    .map((comment) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            "- $comment",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 10),

              //Add Comment Input Box
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
