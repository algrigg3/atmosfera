import 'locationScreen.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String? location; // Optional
  final LatLng? locationCoords;
  final String? address; // Optional address for display
  final String? imageUrl; // Optional
  final String description;

  const PostCard({
    Key? key,
    required this.username,
    this.location,
    this.locationCoords,
    this.address,
    this.imageUrl,
    required this.description,
  }) : super(key: key);

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
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (location != null)
                  GestureDetector(
                    onTap: () {
                      print("Location tapped!"); // ✅ First confirm tap works
                      print("Username: $username");
                      print("Location Name: $location");
                      print("Location Coords: $locationCoords");
                      print("Address: $address");

                      // ✅ Make sure data is NOT NULL and push to LocationDetailScreen
                      if (locationCoords != null && address != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationDetailScreen(
                              username: username,
                              locationName: location!,
                              locationCoords: locationCoords!,
                              address: address!,
                            ),
                          ),
                        );
                      } else {
                        print(
                            "⚠️ Missing data: locationCoords or address is null!");
                      }
                    },
                    child: Text(
                      '@$location',
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
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
            ],

            // ✅ Like, Comment, Pin icons row
            Row(
              children: [
                Icon(Icons.favorite_border),
                SizedBox(width: 10),
                Icon(Icons.comment_outlined),
                Spacer(),
                Icon(Icons.location_pin),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Post description
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            // ✅ View Comments Link
            GestureDetector(
              onTap: () {
                // TODO: Navigate to comments page
              },
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
