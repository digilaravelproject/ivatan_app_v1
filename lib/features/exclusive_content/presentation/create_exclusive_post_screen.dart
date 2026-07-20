import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/exclusive_api_service.dart';

class CreateExclusivePostScreen extends StatefulWidget {
  const CreateExclusivePostScreen({Key? key}) : super(key: key);

  @override
  State<CreateExclusivePostScreen> createState() => _CreateExclusivePostScreenState();
}

class _CreateExclusivePostScreenState extends State<CreateExclusivePostScreen> {
  File? _selectedMedia;
  String _mediaType = 'image'; // image, video
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  final ExclusiveApiService _apiService = Get.put(ExclusiveApiService());

  Future<void> _pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    XFile? pickedFile;
    
    if (isVideo) {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile!.path);
        _mediaType = isVideo ? 'video' : 'image';
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedMedia == null) {
      Get.snackbar("Error", "Please select media for the exclusive post");
      return;
    }

    if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
      Get.snackbar("Error", "Please enter a valid price");
      return;
    }

    double price = double.parse(_priceController.text);
    if (price <= 0) {
      Get.snackbar("Error", "Price must be greater than 0");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.createExclusivePost(
        type: _mediaType == 'image' ? 'post' : 'video',
        caption: _captionController.text,
        visibility: 'public',
        media: _selectedMedia!,
        price: price,
      );

      if (response != null) {
        Get.back();
        Get.snackbar("Success", response['message'] ?? "Exclusive post created successfully.");
      } else {
        Get.snackbar("Error", "Failed to create post. Please try again.");
      }
    } catch (e) {
      debugPrint("Error uploading exclusive post: $e");
      Get.snackbar("Error", "An unexpected error occurred.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Exclusive Post"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _uploadPost,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Post", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Selection
            GestureDetector(
              onTap: () {
                _showMediaPickerOptions(context);
              },
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _selectedMedia != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _mediaType == 'image'
                            ? Image.file(_selectedMedia!, fit: BoxFit.cover)
                            : const Center(child: Icon(Icons.videocam, size: 50, color: Colors.grey)), // Placeholder for video
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Tap to select Media", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Caption
            TextField(
              controller: _captionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write a caption for your exclusive content...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Price
            const Text("Set Price (INR)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.currency_rupee),
                hintText: "e.g. 500",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Followers will need to pay this amount to unlock this content.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMedia(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
