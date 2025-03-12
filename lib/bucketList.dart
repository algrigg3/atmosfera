import 'package:flutter/material.dart';
import 'tabBar.dart';

class BucketList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomTabBar(currentTab: "Bucket List"), // Always on top
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Text(
                    'Recently Saved',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  BucketListItem(), // Example item
                  BucketListItem(),
                  BucketListItem(),
                  BucketListItem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example bucket list item
class BucketListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.location_pin, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@Marina Village posted by NatCarroll45',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      // Navigate to The Now post or detail
                    },
                    child: Text('See The Now',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'images/postCard1.jpg', // Replace with real image
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
