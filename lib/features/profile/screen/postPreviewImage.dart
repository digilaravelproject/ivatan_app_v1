import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/helper/custom_buttons.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:video_player/video_player.dart';
import '../controller/profile_controller.dart';

/*class PreviewScreen extends StatelessWidget {
  PreviewScreen({super.key});

  final controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController(SharedPrefManager().user!.username));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7AB6F0),
            Color(0xFFB3E5F5),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Create Post"),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (controller.imageFile.value != null) {
                    return Center(
                      child: Image.file(
                        controller.imageFile.value!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                  if (controller.videoFile.value != null &&
                      controller.videoController.value != null &&
                      controller.videoController.value!.value.isInitialized) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio:
                        controller.videoController?.value!.volume.aspectRatio,
                        child: VideoPlayer(controller.videoController?.value! as VideoPlayerController),
                      ),
                    );
                  }
                  return const Center(child: Text("No media selected"));
                }),

                const SizedBox(height: 25),

                // ---------------- TYPE DROPDOWN ----------------
                const Text("Select Type"),
                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedType.value,
                    decoration: _box(),
                    items: const [
                      DropdownMenuItem(value: "post", child: Text("Post")),
                      DropdownMenuItem(value: "video", child: Text("Video")),
                      DropdownMenuItem(value: "reel", child: Text("Reel")),
                      DropdownMenuItem(
                        value: "carousel",
                        child: Text("Carousel"),
                      ),
                    ],
                    onChanged: (value) {
                      controller.selectedType.value = value!;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- VISIBILITY DROPDOWN ----------------
                const Text("Select Visibility"),
                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedVisibility.value,
                    decoration: _box(),
                    items: const [
                      DropdownMenuItem(value: "public", child: Text("Public")),
                      DropdownMenuItem(
                        value: "private",
                        child: Text("Private"),
                      ),
                      DropdownMenuItem(
                        value: "friends",
                        child: Text("Friends"),
                      ),
                    ],
                    onChanged: (value) {
                      controller.selectedVisibility.value = value!;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- CAPTION ----------------
                const Text("Caption"),
                const SizedBox(height: 5),

                TextField(
                  controller: controller.captionCtrl,
                  maxLines: 4,
                  decoration: _box(),
                ),

                const SizedBox(height: 30),

                // ---------------- BUTTON ----------------
                Obx(() {
                  return controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : MyButton(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : () => controller.createPost(),
                        title: 'Create Post',
                      );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _box() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}*/

class PreviewScreen extends StatelessWidget {
 // PreviewScreen({super.key});

  final String userName;

  PreviewScreen({super.key, required this.userName,});

  late final controller = Get.find<ProfileController>(tag: userName);

 // final controller = Get.find<ProfileController>();



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7AB6F0),
            Color(0xFFB3E5F5),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Create Post"),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  // IMAGE
                  if (controller.imageFile.value != null) {
                    return Center(
                      child: Image.file(
                        controller.imageFile.value!,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    );
                  }

                  // VIDEO
                  // if (controller.videoFile.value != null &&
                  //     controller.videoController?.value != null &&
                  //     controller.videoController?.value!.value.isInitialized) {
                  //   return Center(
                  //     child: AspectRatio(
                  //       aspectRatio: controller.videoController!.value.aspectRatio,
                  //       child: VideoPlayer(controller.videoController!),
                  //     ),
                  //   );
                  // }


                  if (controller.videoFile.value != null &&
                      controller.videoController != null &&
                      controller.videoController!.value.isInitialized) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio: controller.videoController!.value.aspectRatio,
                        child: VideoPlayer(controller.videoController!),
                      ),
                    );
                  }

                  return const Center(child: Text("No media selected"));
                }),

                const SizedBox(height: 25),

                const Text("Select Type"),
                const SizedBox(height: 5),

                Obx(
                      () => DropdownButtonFormField<String>(
                    value: controller.selectedType.value,
                    decoration: _box(),
                    items: const [
                      DropdownMenuItem(value: "post", child: Text("Post")),
                      DropdownMenuItem(value: "video", child: Text("Video")),
                      DropdownMenuItem(value: "reel", child: Text("Reel")),
                      DropdownMenuItem(value: "carousel", child: Text("Carousel")),
                    ],
                    onChanged: (value) {
                      controller.selectedType.value = value!;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Select Visibility"),
                const SizedBox(height: 5),

                Obx(
                      () => DropdownButtonFormField<String>(
                    value: controller.selectedVisibility.value,
                    decoration: _box(),
                    items: const [
                      DropdownMenuItem(value: "public", child: Text("Public")),
                      DropdownMenuItem(value: "private", child: Text("Private")),
                      DropdownMenuItem(value: "friends", child: Text("Friends")),
                    ],
                    onChanged: (value) {
                      controller.selectedVisibility.value = value!;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Caption"),
                const SizedBox(height: 5),

                TextField(
                  controller: controller.captionCtrl,
                  maxLines: 4,
                  decoration: _box(),
                ),

                const SizedBox(height: 30),

                Obx(() {
                  return controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : MyButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.createPost(),
                    title: 'Create Post',
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _box() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

