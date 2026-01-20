import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/features/dashboard/controller/create_story_controller.dart';
import 'package:video_player/video_player.dart';

import '../../../core/helper/custom_buttons.dart';
import '../../../core/theme/app_colors.dart';
/*

class StoryScreen extends StatelessWidget {
  StoryScreen({super.key});

  final controller = Get.find<StoryController>();

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
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   title: const Text("Create Post"),
        // ),

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
                        : () => controller.createStory(),
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

import 'package:get/get.dart';

class StoryScreen extends StatelessWidget {
  StoryScreen({super.key});
  final controller = Get.find<StoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // ------------------ MEDIA PREVIEW (FULL TOP AREA) ------------------
          Positioned.fill(
            child: Obx(() {
              if (controller.imageFile.value != null) {
                return Image.file(
                  controller.imageFile.value!,
               //   fit: BoxFit.fill,
                );
              }

              if (controller.videoFile.value != null &&
                  controller.videoController != null &&
                  controller.videoController!.value.isInitialized) {
                return Center(
                  child: AspectRatio(
                    aspectRatio:
                    controller.videoController!.value.aspectRatio,
                    child: VideoPlayer(controller.videoController!),
                  ),
                );
              }

              return const Center(
                child: Text(
                  "No media selected",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }),
          ),

          // ------------------ BOTTOM SHEET UI ------------------
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add a caption...",
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 8),

                  TextField(
                    controller: controller.captionCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Obx(() {
                    return controller.isLoading.value
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : MyButton(
                      title: "Your Story",
                      onPressed: () => controller.createStory(),
                    );
                  }),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // ------------------ BACK BUTTON ------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
