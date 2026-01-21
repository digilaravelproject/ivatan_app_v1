import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/helper/custom_buttons.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:video_player/video_player.dart';
import '../controller/profile_controller.dart';

class PreviewScreen extends StatelessWidget {
  final String userName;

  PreviewScreen({super.key, required this.userName});

  late final controller = Get.find<ProfileController>(tag: userName);

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
            return controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: () => controller.createPost(),
                    child: const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.blue,
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
                  // Media Preview Section
                  Obx(() {
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

                  const SizedBox(height: 20),

                  // Caption Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                SharedPrefManager().user?.profilePhotoPath != null
                                    ? "https://www.ivatan.in/storage/${SharedPrefManager().user!.profilePhotoPath}"
                                    : "https://ui-avatars.com/api/?name=${SharedPrefManager().user?.name ?? 'User'}&color=7F9CF5&background=EBF4FF",
                              ),
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
                            // Visibility Selector
                            GestureDetector(
                              onTap: () => _showVisibilitySheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
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

                        // Caption Input
                        TextField(
                          controller: controller.captionCtrl,
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
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Action Bar
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
                  onTap: () {
                    // Add location functionality
                  },
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.people_outline,
                  label: "Tag People",
                  onTap: () {
                    // Add tag people functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPostTypeLabel(String type) {
    switch (type) {
      case 'post':
        return 'Post';
      case 'reel':
        return 'Reel';
      case 'video':
        return 'Video';
      case 'carousel':
        return 'Carousel';
      default:
        return 'Post';
    }
  }

  Color _getVisibilityColor(String visibility) {
    switch (visibility) {
      case 'public':
        return Colors.blue;
      case 'private':
        return Colors.orange;
      case 'friends':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'public':
        return Icons.public;
      case 'private':
        return Icons.lock;
      case 'friends':
        return Icons.people;
      default:
        return Icons.public;
    }
  }

  void _showVisibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Who can see this?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            _buildVisibilityOption(
              icon: Icons.public,
              title: "Public",
              subtitle: "Anyone can see this post",
              value: "public",
              color: Colors.blue,
            ),
            _buildVisibilityOption(
              icon: Icons.people,
              title: "Friends",
              subtitle: "Only your friends can see",
              value: "friends",
              color: Colors.green,
            ),
            _buildVisibilityOption(
              icon: Icons.lock,
              title: "Private",
              subtitle: "Only you can see this post",
              value: "private",
              color: Colors.orange,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Obx(() {
      final isSelected = controller.selectedVisibility.value == value;
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : Icon(Icons.circle_outlined, color: Colors.grey.shade300),
        onTap: () {
          controller.selectedVisibility.value = value;
          Get.back();
        },
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Image.file(
              controller.imageFile.value!,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => controller.showPickerOptions(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.videoController!.value.aspectRatio,
              child: VideoPlayer(controller.videoController!),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => controller.showPickerOptions(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if (controller.videoController!.value.isPlaying) {
                  controller.videoController!.pause();
                } else {
                  controller.videoController!.play();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
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
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No media selected",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap below to add photos or videos",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.showPickerOptions(),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("Add Media"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
