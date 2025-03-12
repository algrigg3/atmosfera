import 'package:flutter/material.dart';
import 'theNow.dart';
import 'bucketList.dart';
import 'createPost.dart';
import 'searchScreen.dart';
import 'profile.dart'; // You'll need to create this page

class CustomTabBar extends StatelessWidget {
  final String currentTab;

  const CustomTabBar({Key? key, required this.currentTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(context, "The Now", currentTab == "The Now", TheNow()),
          _buildTab(context, "Bucket List", currentTab == "Bucket List",
              BucketList()),
          _buildIconTab(
              context, currentTab == "Create", CreatePost()), // Plus icon
          _buildTab(context, "Search", currentTab == "Search", SearchScreen()),
          _buildTab(context, "Profile", currentTab == "Profile",
              ProfilePage()), // New profile tab
        ],
      ),
    );
  }

  // Standard text tab
  Widget _buildTab(
      BuildContext context, String label, bool isSelected, Widget page) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Special icon tab for Create (+)
  Widget _buildIconTab(BuildContext context, bool isSelected, Widget page) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Icon(
          Icons
              .add_circle, // You can replace this with Image.asset('images/plus.png') if you have a custom image
          color: isSelected ? Colors.white : Colors.white70,
          size: 30,
        ),
      ),
    );
  }
}
