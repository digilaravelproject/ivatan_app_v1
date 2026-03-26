import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:video_player/video_player.dart';
import '../controller/profile_controller.dart';
import 'image_edit_screen.dart';
import 'video_edit_screen.dart';

class PreviewScreen extends StatefulWidget {
  final String userName;

  PreviewScreen({super.key, required this.userName});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late final ProfileController controller;
  final RxInt currentCarouselIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>(tag: widget.userName);
    controller.captionCtrl.clear();
    controller.titleCtrl.clear();
    controller.currentCaption.value = "";
    controller.currentTitle.value = "";
    controller.homeController.trimStartTime.value = 0.0;
    controller.homeController.trimDuration.value = 0.0;
  }

  void _openEditor() async {
    final type = controller.selectedType.value;
    
    if (type == 'post' || type == 'carousel') {
      final result = await Get.to(() => ImageEditScreen(
        file: controller.imageFile.value!,
        userName: widget.userName,
      ));
      
      if (result != null && result is File) {
        // Sync both to avoid original image being used in createPost
        if (controller.imageFiles.isNotEmpty) {
          int indexToUpdate = (type == 'carousel') ? currentCarouselIndex.value : 0;
          if (indexToUpdate < controller.imageFiles.length) {
             controller.imageFiles[indexToUpdate] = result;
          }
        }
        controller.imageFile.value = result;
      }
    } else if (type == 'reel' || type == 'video') {
      if (controller.videoFile.value == null) {
        Get.snackbar("Error", "Video file not found. Please re-select the video.");
        return;
      }
      
      final result = await Get.to(() => VideoEditScreen(
        file: controller.videoFile.value!,
        isReel: type == 'reel',
      ));
      
      if (result != null && result is Map) {
        controller.homeController.trimStartTime.value = result['startTime'];
        controller.homeController.trimDuration.value = result['duration'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          "Create ${_getPostTypeLabel(controller.selectedType.value)}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        )),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            
            // Validation Logic for Share Button
            final type = controller.selectedType.value;
            bool isValid = true;
            if (type == 'video') {
              isValid = controller.currentTitle.value.trim().isNotEmpty && 
                        controller.currentCaption.value.trim().isNotEmpty;
            } else {
              // For others, caption is required for now as per user "reqired kr dena"
              isValid = controller.currentCaption.value.trim().isNotEmpty;
            }

            return TextButton(
              onPressed: isValid ? () => controller.createPost() : null,
              child: Text(
                "Share",
                style: TextStyle(
                  color: isValid ? Colors.blue : Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Obx(() {
                        if (controller.imageFiles.length > 1) {
                          return _buildCarouselPreview();
                        }
                        if (controller.imageFile.value != null) {
                          return _buildImagePreview();
                        }
                        if (controller.videoFile.value != null &&
                            controller.videoController != null &&
                            controller.videoController!.value.isInitialized) {
                          return _buildVideoPreview();
                        }
                        return _buildNoMediaPlaceholder();
                      }),
                      
                      // Edit Icon Launcher
                      _buildEditLauncher(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: SharedPrefManager().user?.profilePhotoPath != null
                                  ? NetworkImage("https://www.ivatan.in/storage/${SharedPrefManager().user!.profilePhotoPath}")
                                  : null,
                              child: SharedPrefManager().user?.profilePhotoPath == null
                                  ? const Icon(Icons.person, color: Colors.grey, size: 24)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    SharedPrefManager().user?.name ?? "User",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getVisibilityColor(controller.selectedVisibility.value),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getVisibilityIcon(controller.selectedVisibility.value),
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          controller.selectedVisibility.value.capitalize ?? "Public",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showVisibilitySheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Change",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade700),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        Obx(() {
                          final type = controller.selectedType.value;
                          if (type == 'video') {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller.titleCtrl,
                                        onChanged: (v) => controller.currentTitle.value = v,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                          hintText: "Write a title...",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Obx(() => (controller.currentTitle.value.trim().isEmpty)
                                      ? const Text("*", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))
                                      : const SizedBox.shrink()),
                                  ],
                                ),
                                Divider(color: Colors.grey.shade100, height: 20),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.captionCtrl,
                                onChanged: (v) => controller.currentCaption.value = v,
                                maxLines: null,
                                minLines: 3,
                                decoration: InputDecoration(
                                  hintText: "Write a caption...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            Obx(() => (controller.currentCaption.value.trim().isEmpty)
                                ? const Text("*", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))
                                : const SizedBox.shrink()),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.location_on_outlined,
                  label: "Location",
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.people_outline,
                  label: "Tag People",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditLauncher() {
    return Obx(() {
      final type = controller.selectedType.value;
      if (type == 'video') return const SizedBox.shrink(); // No edit for long videos

      return Positioned(
        top: 15,
        right: 15,
        child: GestureDetector(
          onTap: _openEditor,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(
              type == 'reel' ? Icons.video_settings : Icons.brush,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCarouselPreview() {
    final PageController pageController = PageController();
    final RxInt currentIndex = 0.obs;

    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: controller.imageFiles.length,
            onPageChanged: (index) {
               currentCarouselIndex.value = index;
               // Also sync the "primary" image for editing consistency
               controller.imageFile.value = controller.imageFiles[index];
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.file(
                  controller.imageFiles[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.imageFiles.length,
                (index) => Obx(() => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentCarouselIndex.value == index
                        ? Colors.blue
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      color: Colors.black,
      child: Center(
        child: Obx(() => Image.file(
          controller.imageFile.value!,
          fit: BoxFit.contain,
        )),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.videoController?.value.aspectRatio ?? 16/9,
          child: controller.videoController != null ? VideoPlayer(controller.videoController!) : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildNoMediaPlaceholder() {
    return Container(
      width: double.infinity,
      height: 350,
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text("No media selected", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.showPickerOptions(),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("Add Media"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getPostTypeLabel(String type) {
    switch (type) {
      case 'post': return 'Post';
      case 'reel': return 'Reel';
      case 'video': return 'Video';
      case 'carousel': return 'Carousel';
      default: return 'Post';
    }
  }

  Color _getVisibilityColor(String visibility) {
    switch (visibility) {
      case 'public': return Colors.blue;
      case 'private': return Colors.orange;
      case 'friends': return Colors.green;
      default: return Colors.blue;
    }
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'public': return Icons.public;
      case 'private': return Icons.lock;
      case 'friends': return Icons.people;
      default: return Icons.public;
    }
  }

  void _showVisibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 6), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const Padding(padding: EdgeInsets.all(16.0), child: Text("Who can see this?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            _buildVisibilityOption(icon: Icons.public, title: "Public", subtitle: "Anyone can see this post", value: "public", color: Colors.blue),
            _buildVisibilityOption(icon: Icons.people, title: "Friends", subtitle: "Only your friends can see", value: "friends", color: Colors.green),
            _buildVisibilityOption(icon: Icons.lock, title: "Private", subtitle: "Only you can see this post", value: "private", color: Colors.orange),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({required IconData icon, required String title, required String subtitle, required String value, required Color color}) {
    return Obx(() {
      final isSelected = controller.selectedVisibility.value == value;
      return ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : Icon(Icons.circle_outlined, color: Colors.grey.shade300),
        onTap: () { controller.selectedVisibility.value = value; Get.back(); },
      );
    });
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 20, color: Colors.grey.shade700), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700))]))));
  }
}
