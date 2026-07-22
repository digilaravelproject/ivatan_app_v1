import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _videoController;

  final ExclusiveApiService _apiService = Get.put(ExclusiveApiService());

  @override
  void dispose() {
    _captionController.dispose();
    _priceController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    XFile? pickedFile;
    
    if (isVideo) {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      _videoController?.dispose();
      _videoController = null;
      
      setState(() {
        _selectedMedia = File(pickedFile!.path);
        _mediaType = isVideo ? 'video' : 'image';
      });

      if (isVideo) {
        _videoController = VideoPlayerController.file(_selectedMedia!)
          ..initialize().then((_) {
            setState(() {}); // Update UI after video initializes
            _videoController!.setLooping(true);
            _videoController!.play();
          });
      }
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedMedia == null) {
      Get.snackbar("Media Required", "Please select a photo or video to post.",
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }

    if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
      Get.snackbar("Price Required", "Please enter a valid price to lock this post.",
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }

    double price = double.parse(_priceController.text);
    if (price <= 0) {
      Get.snackbar("Invalid Price", "Price must be greater than 0.",
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
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
        Get.snackbar("Success", response['message'] ?? "Exclusive post created successfully.",
            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), backgroundColor: Colors.green.shade100);
      } else {
        Get.snackbar("Upload Failed", "Failed to create post. Please try again.",
            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      debugPrint("Error uploading exclusive post: $e");
      Get.snackbar("Error", "An unexpected error occurred.",
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), backgroundColor: Colors.red.shade100);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "New Exclusive Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        actions: [
          _isLoading 
            ? const Center(child: Padding(padding: EdgeInsets.only(right: 16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))))
            : TextButton(
                onPressed: _uploadPost,
                child: Text(
                  "Share",
                  style: TextStyle(
                    color: _selectedMedia == null ? Colors.blue.withOpacity(0.5) : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Media Preview and Caption Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Preview Square
                  GestureDetector(
                    onTap: () => _showMediaPickerOptions(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                      ),
                      child: _selectedMedia == null
                          ? const Center(child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 30))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _mediaType == 'video' && _videoController != null && _videoController!.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio: 1,
                                      child: VideoPlayer(_videoController!),
                                    )
                                  : Image.file(_selectedMedia!, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Caption Input
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: 2200, // Insta style limit
                      decoration: const InputDecoration(
                        hintText: "Write a caption...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        counterText: "",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
            
            // Premium Settings Section
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                "Exclusive Settings",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ),
            
            // Price Input Tile
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Unlock Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 2),
                        Text("Amount followers pay to view", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sleek Price Input
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        prefixText: "₹ ",
                        prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        hintText: "0.00",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 0.5, color: Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Select Media Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_outlined, color: Colors.blue),
                  ),
                  title: const Text('Library Photo', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(false);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.videocam_outlined, color: Colors.red),
                  ),
                  title: const Text('Library Video', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(true);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
