import 'package:flutter/material.dart';

class TheNow extends StatelessWidget {
  const TheNow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo and Tabs
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('images/Atmosfera (1).png', height: 40), // Logo
                  // You can add profile pic or menu icon here later
                ],
              ),
            ),
            // Tab Bar (Fixed at the top)
            Container(
              color: Colors.blueAccent[700],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(context, "The Now", true),
                  _buildTab(context, "Bucket List", false),
                  _buildTab(context, "Create", false),
                  _buildTab(context, "Search", false),
                ],
              ),
            ),
            // Posts Feed (Scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildPostCard(
                    username: "skyWood12",
                    content: "Whats everyone up to? It's Friday night!!",
                  ),
                  _buildPostCard(
                    username: "NatCarroll45",
                    location: "@Marina Village",
                    image:
                        'images/post_image.jpg', // Replace with actual image path
                    content:
                        "The Girls and I just got here! Meet us at the bar!!",
                  ),
                  // Add more post cards dynamically later
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab Builder
  Widget _buildTab(BuildContext context, String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Navigation logic between tabs goes here
        print("Navigated to $title");
        // You can use Navigator.push() to move between pages (Bucket List, Create, etc.)
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Post Card Builder
  Widget _buildPostCard({
    required String username,
    String? location,
    String? image,
    required String content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username and location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (location != null)
                  Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Image if available
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            if (image != null) const SizedBox(height: 10),
            // Content
            Text(
              content,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            // Action icons (Like, Comment, Pin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 20),
                    SizedBox(width: 10),
                    Icon(Icons.chat_bubble_outline, size: 20),
                  ],
                ),
                Icon(Icons.push_pin_outlined, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            // View Comments Button
            GestureDetector(
              onTap: () {
                // You can navigate to comments screen here
                print("View comments tapped");
              },
              child: Text(
                "View Comments",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
