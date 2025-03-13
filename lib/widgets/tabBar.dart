import 'package:flutter/material.dart';
import '../screens/theNow.dart';
import '../screens/bucketList.dart';
import '../screens/createPost.dart';
import '../screens/searchScreen.dart';
import '../screens/profile.dart';

class CustomTabBar extends StatelessWidget {
  final String currentTab;
  final String currentUserId;

  const CustomTabBar(
      {Key? key, required this.currentTab, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(context, "The Now", currentTab == "The Now",
              TheNow(userId: currentUserId)),
          _buildTab(context, "Bucket List", currentTab == "Bucket List",
              BucketList(userId: currentUserId)),
          _buildIconTab(context, currentTab == "Create",
              CreatePost(userId: currentUserId)),
          _buildTab(context, "Search", currentTab == "Search",
              SearchScreen(userId: currentUserId)),
          _buildTab(context, "Profile", currentTab == "Profile",
              ProfilePage(userId: currentUserId)),
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
          Icons.add_circle, // Customizable icon
          color: isSelected ? Colors.white : Colors.white70,
          size: 30,
        ),
      ),
    );
  }
}
