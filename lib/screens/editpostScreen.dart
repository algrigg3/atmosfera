import 'package:atmosfera/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:image_picker_web/image_picker_web.dart';
import 'package:atmosfera/services/post_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onUpdated;

  const EditPostScreen({
    Key? key,
    required this.post,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _captionController;
  String selectedCategory = '';
  bool isSaving = false;

  final List<String> categories = [
    'Coffee Shops',
    'Restaurants',
    'Adventure',
    'Activity',
    'Bars',
  ];

  File? _imageFile;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    selectedCategory = widget.post.category;
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
    } else if (widget.post.media != null &&
        widget.post.media!.startsWith("http")) {
      return Image.network(widget.post.media!, height: 200);
    } else {
      return const Text("No image selected");
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final success = await PostService().updatePost(
      postId: widget.post.id,
      caption: _captionController.text.trim(),
      category: selectedCategory,
      imageFile: _imageFile,
      webImage: _webImage,
    );

    if (success) {
      widget.onUpdated();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update post')),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Caption is required'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value:
                    selectedCategory.isEmpty ? categories[0] : selectedCategory,
                items: categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
