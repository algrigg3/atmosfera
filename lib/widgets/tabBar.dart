import 'package:flutter/material.dart';
import '../screens/theNow.dart';
import '../screens/createPost.dart';
import '../screens/searchScreen.dart';
import '../screens/profile.dart';
import '../screens/Notifications.dart';

class CustomTabBar extends StatefulWidget {
  final String currentTab;
  final String currentUserId;

  const CustomTabBar({
    Key? key,
    required this.currentTab,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  String hoveredTab = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 0),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                'images/Atmosfera (1).png',
                fit: BoxFit.contain,
                height: 60,
              ),
            ),
          ),
          _buildNavItem(
            context,
            label: "The Now",
            icon: Icons.dynamic_feed,
            isSelected: widget.currentTab == "The Now",
            page: TheNow(userId: widget.currentUserId),
          ),
          _buildNavItem(
            context,
            label: "Search",
            icon: Icons.search,
            isSelected: widget.currentTab == "Search",
            page: SearchScreen(userId: widget.currentUserId),
          ),
          const Divider(color: Colors.white24),
          _buildNavIcon(
            context,
            icon: Icons.add_circle,
            isSelected: widget.currentTab == "Create",
            page: CreatePost(userId: widget.currentUserId),
          ),
          const Divider(color: Colors.white24),
          _buildNavItem(
            context,
            label: "Notifications",
            icon: Icons.notifications,
            isSelected: widget.currentTab == "Notifications",
            page: NotificationPage(userId: widget.currentUserId),
          ),
          _buildNavItem(
            context,
            label: "Profile",
            icon: Icons.person,
            isSelected: widget.currentTab == "Profile",
            page: ProfilePage(userId: widget.currentUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context,
      {required String label,
      required IconData icon,
      required bool isSelected,
      required Widget page}) {
    final isHovered = hoveredTab == label;
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredTab = label),
      onExit: (_) => setState(() => hoveredTab = ""),
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: isSelected
              ? Colors.blue[700]
              : isHovered
                  ? Colors.blue[800]
                  : Colors.transparent,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context,
      {required IconData icon,
      required bool isSelected,
      required Widget page}) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoveredTab = "Create"),
      onExit: (_) => setState(() => hoveredTab = ""),
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Icon(
            icon,
            size: 34,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
