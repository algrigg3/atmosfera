import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/tabBar.dart';
import 'theNow.dart';

class LocationDetailScreen extends StatefulWidget {
  final String username;
  final String locationName;
  final LatLng locationCoords;
  final String address;
  final String userId;

  LocationDetailScreen({
    Key? key,
    required this.username,
    required this.locationName,
    required this.locationCoords,
    required this.address,
    required this.userId,
  }) : super(key: key) {
    print("Navigating to LocationDetailScreen with $locationName");
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTabBar(currentTab: "", currentUserId: widget.userId),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Banner
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${widget.username} is @${widget.locationName}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Google Map
                  Center(
                    child: SizedBox(
                      width:
                          800, // Limit width for better centering on big screens
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Distance
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        distanceInMiles != null
                            ? '${widget.username} is ${distanceInMiles!.toStringAsFixed(2)} miles away from your current location'
                            : 'Calculating distance...',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Address
                  Center(
                    child: Text(
                      'Address: ${widget.address}',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Center(
                    child: Wrap(
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Pin logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: const Text('Pin',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TheNow(userId: widget.userId)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: const Text('Back to The Now',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
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
