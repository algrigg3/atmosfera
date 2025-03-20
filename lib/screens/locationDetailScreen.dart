import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationDetailScreen extends StatefulWidget {
  final String username;
  final String locationName;
  final LatLng locationCoords;
  final String address;
  final String userId;

  const LocationDetailScreen({
    Key? key,
    required this.username,
    required this.locationName,
    required this.locationCoords,
    required this.address,
    required this.userId,
  }) : super(key: key);

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
      appBar: AppBar(title: Text('Location Details')),
      body: Column(
        children: [
          SizedBox(height: 10),

          // Location info
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
                  ? 'This location is ${distanceInMiles!.toStringAsFixed(2)} miles away from you'
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

          // Back Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text('Back', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
