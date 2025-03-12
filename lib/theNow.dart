import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'tabBar.dart';
import 'post_card.dart';

class TheNow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ Custom Tab Bar
          CustomTabBar(currentTab: "The Now"),

          // ✅ Post Feed
          Expanded(
            child: ListView(
              children: [
                PostCard(
                  username: "skyWood12",
                  description: "What's everyone up to? It's Friday night!!",
                ),
                PostCard(
                  username: "NatCarroll45",
                  location: "Marina Village",
                  locationCoords:
                      LatLng(26.1224, -80.1373), // ✅ Coordinates (real example)
                  address:
                      "801 Seabreeze Blvd, Fort Lauderdale, FL 33316", // ✅ Real address
                  imageUrl: 'images/postCard1.jpg',
                  description:
                      "The girls and I just got here! Meet us at the bar!!",
                ),
                // Add more PostCards here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
