import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? selectedLocation;
  GoogleMapController? mapController;

  void _onMapTap(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 10,
              ),
              onTap: _onMapTap,
              onMapCreated: (controller) {
                mapController = controller;
              },
              markers: selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId("selected"),
                        position: selectedLocation!,
                      )
                    }
                  : {},
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (selectedLocation != null) {
                Navigator.pop(context, selectedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a location')),
                );
              }
            },
            child: Text('Confirm Location'),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
