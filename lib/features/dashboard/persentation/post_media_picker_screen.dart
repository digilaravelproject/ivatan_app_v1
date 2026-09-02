import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/screen/postPreviewImage.dart';
import 'package:video_compress/video_compress.dart';
import 'story_camera_screen.dart';

class PostMediaPickerScreen extends StatefulWidget {
  final String initialFilter;
  final String initialType;
  const PostMediaPickerScreen({
    Key? key, 
    this.initialFilter = 'Recent',
    this.initialType = 'post',
  }) : super(key: key);

  @override
  State<PostMediaPickerScreen> createState() => _PostMediaPickerScreenState();
}

class _PostMediaPickerScreenState extends State<PostMediaPickerScreen> {
  String? currentUserName = SharedPrefManager().user?.username;
  late ProfileController controller;
  
  List<AssetEntity> mediaList = [];
  List<AssetEntity> selectedMediaList = []; // Multi-select list
  AssetEntity? selectedMedia; // For preview top area
  Uint8List? selectedThumbnail;
  bool isLoading = true;
  
  late String selectedFilter;
  final List<String> filters = ['Recent', 'Photos', 'Videos'];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    // Initialize ProfileController for current user
    controller = Get.put(ProfileController(currentUserName ?? ""), tag: currentUserName ?? "");
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

  Future<void> _selectMedia(AssetEntity asset, {bool forceSelect = false}) async {
    final thumb = await asset.thumbnailDataWithSize(
      const ThumbnailSize(400, 400),
    );

    setState(() {
      selectedMedia = asset;
      selectedThumbnail = thumb;

      if (asset.type == AssetType.video) {
        // Videos are always single-select
        selectedMediaList = [asset];
      } else {
        // Images support multi-select
        final existingIndex = selectedMediaList.indexWhere((e) => e.id == asset.id);
        if (existingIndex != -1) {
          if (!forceSelect) {
            selectedMediaList.removeAt(existingIndex);
            // If we removed the currently previewed media, preview the last one in list
            if (selectedMediaList.isEmpty) {
              selectedMedia = null;
              selectedThumbnail = null;
            } else {
              _selectMedia(selectedMediaList.last, forceSelect: true);
            }
          }
        } else {
          // If previous selection was a video, clear it
          if (selectedMediaList.isNotEmpty && selectedMediaList.first.type == AssetType.video) {
            selectedMediaList.clear();
          }
          selectedMediaList.add(asset);
        }
      }
    });
  }

  Future<void> _useSelectedMedia() async {
    if (selectedMediaList.isEmpty) {
      Get.snackbar("Notice", "Please select at least one image or video");
      return;
    }

    // Determine type
    String finalType = widget.initialType;
    if (finalType == 'post' || finalType == 'carousel') {
      finalType = selectedMediaList.length > 1 ? 'carousel' : 'post';
    }

    // Set type in controller
    controller.selectedType.value = finalType;
    controller.selectedVisibility.value = 'public';

    // Clear previous media
    controller.imageFiles.clear();
    controller.imageFile.value = null;
    controller.videoFile.value = null;

    setState(() => isLoading = true);

    try {
      if (selectedMediaList.first.type == AssetType.video) {
        // Handle Video (single) - DEFERRED COMPRESSION
        final file = await selectedMediaList.first.file;
        if (file == null) return;

        // Just set the original file and navigate
        controller.videoFile.value = file;
        
        final videoController = VideoPlayerController.file(file);
        await videoController.initialize();
        controller.videoController = videoController;
        controller.isVideoInitialized.value = true;
      } else {
        // Handle Images (single or multi)
        for (final asset in selectedMediaList) {
          final file = await asset.file;
          if (file != null) {
            controller.imageFiles.add(file);
          }
        }
        if (controller.imageFiles.isNotEmpty) {
          controller.imageFile.value = controller.imageFiles.first;
        }
      }
    } catch (e) {
      print("Processing error: $e");
    } finally {
      setState(() => isLoading = false);
    }

    // Navigate to preview screen
    if (Get.isOverlaysOpen) Get.back();
    Get.off(() => PreviewScreen(userName: currentUserName ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Post',
          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.white),
                onPressed: () {
                  final RenderBox? button = context.findRenderObject() as RenderBox?;
                  final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
                  
                  if (button == null || !button.hasSize || overlay == null || !overlay.hasSize) {
                    return;
                  }
                  
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  showMenu<String>(
                    context: context,
                    position: position,
                    items: filters.map((filter) {
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
                  ).then((value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                      });
                      _loadMedia();
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area (top) - Square format
          Container(
            height: MediaQuery.of(context).size.width, // Square height = width
            color: AppColors.premiumGold,
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
                            color: AppColors.white,
                          ),
                        ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: _useSelectedMedia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: AppColors.white,
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
                      // Square format indicator
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Square (1:1)',
                            style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 64, color: AppColors.premiumGold),
                        const SizedBox(height: 16),
                        Text(
                          'Select a photo or video',
                          style: TextStyle(color: AppColors.premiumGold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
          ),
          
          const SizedBox(height: 8),
          
          // Grid area (bottom) - Square aspect ratio
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.white))
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1, // Square grid items
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
            const Icon(Icons.camera_alt, color: AppColors.white, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Camera',
              style: TextStyle(
                color: AppColors.white,
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
        future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)), // Square thumbnails
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
                    // Selection indicator for carousel
                    if (asset.type == AssetType.image)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: selectedMediaList.any((e) => e.id == asset.id)
                                ? Colors.blue
                                : AppColors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 1.5),
                          ),
                          child: selectedMediaList.any((e) => e.id == asset.id)
                              ? Center(
                                  child: Text(
                                    (selectedMediaList.indexWhere((e) => e.id == asset.id) + 1).toString(),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    if (asset.type == AssetType.video)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam, color: AppColors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(asset.duration),
                                style: const TextStyle(color: AppColors.white, fontSize: 10),
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
              color: AppColors.premiumGold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
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
    Get.to(() => StoryCameraScreen(
      onMediaCaptured: (File file) async {
        Get.back(); // Close camera screen
        
        // Determine file type (simple check by extension or assumption based on capture mode)
        // Since we don't have easy mime check here, we can infer or check extension
        final isVideo = file.path.toLowerCase().endsWith('.mp4');
        
        if (isVideo) {
          controller.videoFile.value = file;
          controller.imageFile.value = null;
          
          final videoController = VideoPlayerController.file(file);
          await videoController.initialize();
          controller.videoController = videoController;
          controller.isVideoInitialized.value = true;
        } else {
          controller.imageFile.value = file;
          controller.videoFile.value = null;
        }

        controller.selectedType.value = 'post';
        controller.selectedVisibility.value = 'public';
        
        Get.back(); // Close picker bottom sheet if still open (not needed if we navigated away)
        Get.to(() => PreviewScreen(userName: currentUserName ?? ""));
      },
    ));
  }
}
