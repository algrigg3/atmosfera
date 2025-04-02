import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../services/post_service.dart';
import '../widgets/tabBar.dart';
import 'locationDetailScreen.dart'; // Import for viewing location details
import 'selectLocationScreen.dart'; // Import for selecting location manually

class CreatePost extends StatefulWidget {
  final String userId;

  const CreatePost({Key? key, required this.userId}) : super(key: key);
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  File? _imageFile; //for mobile
  Uint8List? _webImage; //for web

  String? _selectedCategory;
  bool isPosting = false;

  String locationName = "Fetching location...";
  LatLng? selectedCoords;
  String address = "Detecting...";

  final List<String> _categories = [
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// **Fetch the user's current location**
  Future<void> _getUserLocation() async {
    print("Fetching user location...");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => locationName = "⚠ Location services disabled.");
        print("Error: Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => locationName = "⚠ Location permission denied.");
          print("Error: Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
            () => locationName = " Location permission permanently denied.");
        print("Error: Location permission permanently denied.");
        return;
      }

      // Get user coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("User location: ${position.latitude}, ${position.longitude}");

      // Attempt to fetch placemark (reverse geocoding)
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        print("Error fetching placemarks: $e");
      }

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          selectedCoords = LatLng(position.latitude, position.longitude);
          locationName = "${place.locality}, ${place.country}";
          address =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
        print("Location fetched: $locationName");
      } else {
        // 🔹 Fallback if placemarks fail
        setState(() {
          selectedCoords = LatLng(position.latitude, position.longitude);
          locationName = " ${position.latitude}, ${position.longitude}";
          address = "Unknown location";
        });
        print("Error: No placemarks found, using coordinates instead.");
      }
    } catch (e) {
      setState(() => locationName = "⚠ Error fetching location.");
      print("Exception in _getUserLocation(): $e");
    }
  }

  /// **Let user select a location manually from Google Maps**
  Future<void> _selectLocation() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationScreen()),
    );

    if (pickedLocation != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pickedLocation.latitude,
        pickedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          selectedCoords = pickedLocation;
          locationName = "${place.locality}, ${place.country}";
          address =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    }
  }

  /// **View the selected location in detail**
  void _viewLocationDetails() {
    if (selectedCoords != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationDetailScreen(
            username: "You",
            locationName: locationName,
            locationCoords: selectedCoords!,
            address: address,
            userId: widget.userId,
          ),
        ),
      );
    }
  }

  /// **Pick an image from the gallery**
  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedBytes = await ImagePickerWeb.getImageAsBytes();
      if (pickedBytes != null) {
        setState(() {
          _webImage = pickedBytes;
        });
      }
    } else {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, height: 200);
    } else if (_imageFile != null) {
      return Image.file(_imageFile!, height: 200);
    } else {
      return const Text("No image selected");
    }
  }

  /// **Submit the post with the selected location**
  Future<void> _submitPost() async {
    if (_captionController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    PostService postService = PostService();
    bool success = await postService.createPost(
      userId: widget.userId,
      caption: _captionController.text.trim(),
      category: _selectedCategory!,
      location: locationName, // Use selected location
      imageFile: _imageFile,
      webImage: _webImage,
    );

    setState(() {
      isPosting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Post created successfully!')),
      );

      // **Clear fields after posting**
      setState(() {
        _captionController.clear();
        _detailsController.clear();
        _imageFile = null;
        _selectedCategory = null;
        _getUserLocation(); // Reset to current location
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Failed to create post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomTabBar(currentTab: "Create", currentUserId: widget.userId),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: "Select Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  /// **Location Selection**
                  GestureDetector(
                    onTap: _selectLocation,
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationName,
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  if (selectedCoords != null)
                    ElevatedButton(
                      onPressed: _viewLocationDetails,
                      child: Text("View on Map"),
                    ),

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildImagePreview(),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: _captionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Add a caption",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  ),
                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: isPosting ? null : _submitPost,
                    child: isPosting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Post'),
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
