import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
//import 'package:flutter_google_places/flutter_google_places.dart';

const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // 🔐 Replace this

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? selectedLocation;
  GoogleMapController? mapController;
  CameraPosition? initialCameraPosition;
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapsApiKey);
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        initialCameraPosition = CameraPosition(
          target: selectedLocation!,
          zoom: 14,
        );
        isLoading = false;
      });
    } catch (e) {
      print("Error setting initial location: $e");
      setState(() {
        initialCameraPosition = CameraPosition(
          target: LatLng(37.7749, -122.4194), // fallback: San Francisco
          zoom: 10,
        );
        isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
  }

  Future<void> _searchPlace(String input) async {
    print("🔍 User submitted search: $input");

    if (input.trim().isEmpty) {
      print("⚠️ Empty input, ignoring search.");
      return;
    }

    try {
      final response = await _places.autocomplete(input, language: 'en');
      print("✅ Autocomplete response received");

      if (response.isOkay) {
        print("📦 Found ${response.predictions.length} predictions");

        if (response.predictions.isEmpty) {
          print("❌ No predictions found.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No results. Try a different place.")),
          );
          return;
        }

        final placeId = response.predictions.first.placeId;
        print("👉 Using placeId: $placeId");

        final detail = await _places.getDetailsByPlaceId(placeId!);
        print("✅ Got place details for ${detail.result.name}");

        final location = detail.result.geometry?.location;
        if (location != null) {
          final coords = LatLng(location.lat, location.lng);
          print("📍 Location: ${coords.latitude}, ${coords.longitude}");

          setState(() {
            selectedLocation = coords;
            _searchController.text = detail.result.name;
            _searchFocusNode.unfocus();
          });

          mapController?.animateCamera(CameraUpdate.newLatLngZoom(coords, 16));
        } else {
          print("❌ No geometry found for selected place.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location unavailable. Try another.")),
          );
        }
      } else {
        print("❌ Autocomplete failed: ${response.errorMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.errorMessage}")),
        );
      }
    } catch (e, stack) {
      print("❌ Exception in _searchPlace: $e");
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while searching.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onSubmitted: _searchPlace,
                    decoration: InputDecoration(
                      hintText: 'Search for a place',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: initialCameraPosition!,
                    onMapCreated: (controller) => mapController = controller,
                    onTap: _onMapTap,
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
