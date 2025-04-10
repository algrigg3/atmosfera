import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/post_service.dart';
import '../services/location_service.dart'; // ✅ NEW import
import '../widgets/tabBar.dart';
import 'locationDetailScreen.dart';
import 'selectLocationScreen.dart';

class CreatePost extends StatefulWidget {
  final String userId;

  const CreatePost({Key? key, required this.userId}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage;

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

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => locationName = "⚠ Location services disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => locationName = "⚠ Location permission denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
            () => locationName = "⚠ Location permission permanently denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coords = LatLng(position.latitude, position.longitude);
      selectedCoords = coords;

      try {
        final result = await LocationService.reverseGeocode(coords);
        setState(() {
          locationName = result['locationName']!;
          address = result['address']!;
        });
      } catch (e) {
        print("Reverse geocoding error: $e");
        setState(() {
          locationName =
              "${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}";
          address = "Unknown location";
        });
      }
    } catch (e) {
      print("Location error: $e");
      setState(() => locationName = "⚠ Error fetching location.");
    }
  }

  Future<void> _selectLocation() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationScreen()),
    );

    if (pickedLocation != null) {
      selectedCoords = pickedLocation;

      try {
        final result = await LocationService.reverseGeocode(pickedLocation);
        setState(() {
          locationName = result['locationName']!;
          address = result['address']!;
        });
      } catch (e) {
        print("Manual location error: $e");
        setState(() {
          locationName =
              "${pickedLocation.latitude.toStringAsFixed(4)}, ${pickedLocation.longitude.toStringAsFixed(4)}";
          address = "Unknown location";
        });
      }
    }
  }

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

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedBytes = await ImagePickerWeb.getImageAsBytes();
      if (pickedBytes != null) {
        setState(() => _webImage = pickedBytes);
      }
    } else {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _imageFile = File(image.path));
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

  Future<void> _submitPost() async {
    if (_captionController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isPosting = true);

    PostService postService = PostService();
    bool success = await postService.createPost(
      userId: widget.userId,
      caption: _captionController.text.trim(),
      category: _selectedCategory!,
      location: locationName,
      locationData: selectedCoords != null
          ? {
              'type': 'Point',
              'coordinates': [
                selectedCoords!.longitude,
                selectedCoords!.latitude
              ],
              'address': address,
            }
          : null,
      imageFile: _imageFile,
      webImage: _webImage,
    );

    setState(() => isPosting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );
      setState(() {
        _captionController.clear();
        _detailsController.clear();
        _imageFile = null;
        _webImage = null;
        _selectedCategory = null;
        _getUserLocation(); // reset location
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
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
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                  SizedBox(height: 16),
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
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
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
