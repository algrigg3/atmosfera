import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'tabBar.dart';
import 'theNow.dart';

class LocationDetailScreen extends StatefulWidget {
  final String username;
  final String locationName;
  final LatLng locationCoords;
  final String address;
  final String userId;

  // ❌ DO NOT USE "const" because we are using a body with print
  LocationDetailScreen({
    Key? key,
    required this.username,
    required this.locationName,
    required this.locationCoords,
    required this.address,
    required this.userId,
  }) : super(key: key) {
    print(
        "Navigating to LocationDetailScreen with $locationName"); // ✅ This should print when you tap
  }

  @override
  _LocationDetailScreenState createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  double? distanceInMiles;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double distanceInMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      widget.locationCoords.latitude,
      widget.locationCoords.longitude,
    );
    double distanceInMilesCalc = distanceInMeters / 1609.34;

    setState(() {
      distanceInMiles = distanceInMilesCalc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomTabBar(
              currentTab: "",
              currentUserId: widget
                  .userId), // Or omit currentTab if you want to hide highlight
          SizedBox(height: 10),

          // Top user and location info
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${widget.username} is @${widget.locationName}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 10),

          // Google Maps view
          Container(
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.locationCoords,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('post_location'),
                  position: widget.locationCoords,
                ),
              },
              zoomControlsEnabled: false,
            ),
          ),
          SizedBox(height: 10),

          // Distance display
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.teal,
            child: Text(
              distanceInMiles != null
                  ? '${widget.username} is ${distanceInMiles!.toStringAsFixed(2)} miles away from your current location'
                  : 'Calculating distance...',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),

          // Address display
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Address: ${widget.address}',
              style:
                  TextStyle(decoration: TextDecoration.underline, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Handle Pin action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Pin', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TheNow(userId: widget.userId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Back to The Now',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
