import 'package:flutter/material.dart';
import 'tabBar.dart';

class CreatePost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ Custom Tab Bar
          CustomTabBar(currentTab: "Create"),

          // ✅ Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Location',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Image upload placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Add Image',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Caption input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Caption',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Delete and Post buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Add delete logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        child: Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Add post logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        child:
                            Text('Post', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Details input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'The details',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
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
