import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  final String postOwner;

  const CommentPage({Key? key, required this.postId, required this.postOwner})
      : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<String> comments = []; // Dummy list for now, replace with real data
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments(); // Fetch comments on load
  }

  void fetchComments() async {
    // TODO: Fetch from backend
    print("Fetching comments for Post ID: ${widget.postId}");
    // Simulated response:
    setState(() {
      comments = ["Nice spot!", "Wish I was there!", "Looks fun!"];
    });
  }

  void addComment(String comment) async {
    if (comment.trim().isEmpty) return;
    // TODO: Send to backend
    print("Adding comment: $comment to post ID: ${widget.postId}");

    // Simulate adding comment to list:
    setState(() {
      comments.add(comment);
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments on ${widget.postOwner}\'s post'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(comments[index]),
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                  onPressed: () => addComment(_commentController.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
