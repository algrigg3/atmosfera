import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/post_service.dart';
import '../widgets/tabBar.dart';

class CreatePost extends StatefulWidget {
  final String userId;

  const CreatePost({Key? key, required this.userId}) : super(key: key);
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  String? _location;
  File? _imageFile;
  String? _selectedCategory;
  bool isPosting = false;

  final List<String> _categories = [
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars',
  ];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_captionController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Please fill in all required fields')),
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
      location: _location,
      imageFile: _imageFile,
    );

    setState(() {
      isPosting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Post created successfully!')),
      );

      // **Clear fields after posting**
      setState(() {
        _captionController.clear();
        _detailsController.clear();
        _location = null;
        _imageFile = null;
        _selectedCategory = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to create post')),
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
                  // ✅ Category dropdown
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

                  // ✅ Location input
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Add a location (optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                    onChanged: (value) => _location = value,
                  ),
                  SizedBox(height: 16),

                  // ✅ Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageFile == null
                          ? Center(child: Text('Add Image'))
                          : Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16),

                  // ✅ Caption input
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

                  // ✅ Post Button
                  ElevatedButton(
                    onPressed: isPosting ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: isPosting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Post', style: TextStyle(color: Colors.white)),
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
