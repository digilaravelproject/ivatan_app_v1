import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import '../controller/create_story_controller.dart';
import 'createStoryScreen.dart';
import 'story_camera_screen.dart';

class StoryMediaPickerScreen extends StatefulWidget {
  const StoryMediaPickerScreen({Key? key}) : super(key: key);

  @override
  State<StoryMediaPickerScreen> createState() => _StoryMediaPickerScreenState();
}

class _StoryMediaPickerScreenState extends State<StoryMediaPickerScreen> {
  final StoryController controller = Get.find<StoryController>();
  
  List<AssetEntity> mediaList = [];
  AssetEntity? selectedMedia;
  Uint8List? selectedThumbnail;
  bool isLoading = true;
  
  String selectedFilter = 'Recent';
  final List<String> filters = ['Recent', 'Photos', 'Videos'];

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() => isLoading = true);
    
    // Request permission
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      Get.snackbar('Permission Denied', 'Please allow access to photos');
      setState(() => isLoading = false);
      return;
    }

    // Get albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: _getRequestType(),
      onlyAll: true,
    );

    if (albums.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    // Get media from first album (recent)
    final List<AssetEntity> media = await albums[0].getAssetListPaged(
      page: 0,
      size: 100,
    );

    setState(() {
      mediaList = media;
      isLoading = false;
      if (media.isNotEmpty) {
        _selectMedia(media[0]);
      }
    });
  }

  RequestType _getRequestType() {
    switch (selectedFilter) {
      case 'Photos':
        return RequestType.image;
      case 'Videos':
        return RequestType.video;
      default:
        return RequestType.common;
    }
  }

  Future<void> _selectMedia(AssetEntity asset) async {
    final thumb = await asset.thumbnailDataWithSize(
      const ThumbnailSize(400, 700),
    );
    
    setState(() {
      selectedMedia = asset;
      selectedThumbnail = thumb;
    });
  }

  Future<void> _useSelectedMedia() async {
    if (selectedMedia == null) return;

    // Get the actual file
    final file = await selectedMedia!.file;
    if (file == null) return;

    // Set media in controller based on type
    if (selectedMedia!.type == AssetType.image) {
      controller.imageFile.value = file;
      controller.originalImageFile.value = file; // Reset original for cropping
      controller.videoFile.value = null;
    } else if (selectedMedia!.type == AssetType.video) {
      controller.videoFile.value = file;
      controller.imageFile.value = null;
      
      // Initialize video controller
      final videoController = VideoPlayerController.file(file);
      await videoController.initialize();
      controller.videoController = videoController;
      controller.isVideoInitialized.value = true;
    }

    // Navigate to story screen
    Get.back(); // Close picker
    Get.to(() => StoryScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Story',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
              _loadMedia();
            },
            itemBuilder: (context) => filters.map((filter) {
              return PopupMenuItem<String>(
                value: filter,
                child: Row(
                  children: [
                    if (selectedFilter == filter)
                      const Icon(Icons.check, size: 20, color: Colors.blue),
                    if (selectedFilter == filter) const SizedBox(width: 8),
                    Text(filter),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area (top)
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            color: Colors.grey.shade900,
            child: selectedThumbnail != null
                ? Stack(
                    children: [
                      Center(
                        child: Image.memory(
                          selectedThumbnail!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (selectedMedia?.type == AssetType.video)
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: _useSelectedMedia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          'Select a photo or video',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 8),
          
          // Grid area (bottom)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 9 / 16,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: mediaList.length + 1, // +1 for camera button
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCameraButton();
                      }
                      
                      final asset = mediaList[index - 1];
                      return _buildMediaItem(asset);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: () => _showCameraOptions(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(AssetEntity asset) {
    return GestureDetector(
      onTap: () => _selectMedia(asset),
      child: FutureBuilder<Uint8List?>(
        future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 350)),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: selectedMedia?.id == asset.id
                    ? Border.all(color: Colors.blue, width: 3)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                    if (asset.type == AssetType.video)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(asset.duration),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showCameraOptions() {
    // Navigate to custom camera screen with filters
    Get.to(() => const StoryCameraScreen());
  }
}
