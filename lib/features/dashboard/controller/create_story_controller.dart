import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart' hide MultipartFile;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:i_vatan_app/core/helper/custom_buttons.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/features/dashboard/controller/homeController.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/helper/story_widget.dart';
import '../../../core/network/api_services.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/screen/postPreviewImage.dart';
import '../persentation/createStoryScreen.dart';
import '../persentation/story_media_picker_screen.dart';
import 'package:dio/dio.dart';
import 'package:image_cropper/image_cropper.dart';


class StoryController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  Rx<File?> imageFile = Rx<File?>(null);
  Rx<File?> originalImageFile = Rx<File?>(null);
  Rx<File?> videoFile = Rx<File?>(null);
  RxBool isVideoInitialized = false.obs;
  RxString videoUrl = "".obs;

  ProfileController controller = Get.put(ProfileController(SharedPrefManager().user!.username));
  final HomeController homeController = Get.put(HomeController());


  //RxList<HighlightStoryModel> highlights = <HighlightStoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
   // fetchHighlightes(userName);
  }


  VideoPlayerController? videoController;
  final ApiServices api = ApiServices();


  // ------------------ FORM FIELDS ---------------------
  RxString selectedType = "post".obs;
  RxString selectedVisibility = "public".obs;
  TextEditingController captionCtrl = TextEditingController();
  int? currentHighlightId;
  int currentStoryId = 0;
  RxBool isLoading = false.obs;

  // ------------------ IMAGE CROPPER ---------------------
  Future<void> cropImage() async {
    if (imageFile.value == null || isLoading.value) return;

    // Safety initialization: If original is missing (e.g. after hot reload), assume current is original
    if (originalImageFile.value == null) {
      originalImageFile.value = imageFile.value;
    }

    try {
      isLoading.value = true;
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: originalImageFile.value!.path, // ALWAYS crop from original
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppColors.primary,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      if (croppedFile != null) {
        imageFile.value = File(croppedFile.path);
      }
    } catch (e) {
      print("Crop Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --------------- PICK MEDIA (YOUR OWN LOGIC CALL HERE) ---------------------
  void setImage(File file) {
    imageFile.value = file;
    originalImageFile.value = file; // Store original
    videoFile.value = null;
  }

  void setVideo(File file) async {
    videoFile.value = file;
    imageFile.value = null;

    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    videoController?.value = controller as VideoPlayerValue;
    controller.play();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      imageFile.value = File(pickedFile.path);
      originalImageFile.value = File(pickedFile.path); // Store original
      Get.to(() => StoryScreen());
    } catch (e) {
      print("Image pick error: $e");
    }
  }


  Future<bool> requestPermissions() async {
    if (await Permission.videos.isDenied || await Permission.photos.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.videos,
        Permission.photos,
      ].request();

      return statuses[Permission.videos]!.isGranted ||
          statuses[Permission.photos]!.isGranted;
    }
    return true;
  }


  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (picked == null) return;

      // Compress video for older devices
      final info = await VideoCompress.compressVideo(
        picked.path,
        quality: VideoQuality.MediumQuality, // 720p safe for all devices
        deleteOrigin: false,
      );

      if (info == null || info.path == null) {
        Get.snackbar("Error", "Failed to compress video.");
        return;
      }

      videoFile.value = File(info.path!);
      videoUrl.value = info.path!;
      print("Video ready: ${videoUrl.value}");

      // Initialize controller
      videoController?.dispose();
      videoController = VideoPlayerController.file(videoFile.value!);

      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();
      isVideoInitialized.value = true;

      Get.to(() => StoryScreen());

    } catch (e) {
      isVideoInitialized.value = false;
      print("Pick video error: $e");
      Get.snackbar(
        "Error",
        "This video cannot be played on this device.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  void showPickerOptions() async {
    // Navigate to Instagram-style media picker screen
    Get.to(() => StoryMediaPickerScreen());
  }


  Future<void> createStory() async {
    try {
      isLoading.value = true;

      List<File> mediaFiles = [];

      if (imageFile.value != null) {
        mediaFiles.add(imageFile.value!);
      } else if (videoFile.value != null) {
        mediaFiles.add(videoFile.value!);
      }

      Map<String, dynamic> body = {
        "caption": captionCtrl.text,
      };

      // Backend usually expects: media[] instead of media[0]
      for (int i = 0; i < mediaFiles.length; i++) {
        body["media"] = mediaFiles[i];
      }

      print("createStoryRequest : $body");

      final response = await api.callPost(
        "api/v1/stories",
        data: body,
        isFormData: true,
      );

      homeController.fetchStories();
      print("story RESPONSE: $response");

      if (response != null) {
        CustomSnackBar.showSuccess(message: '${response["message"]}');
        Get.back();
      }

    } catch (e) {
      print("POST ERROR: $e");
      Get.snackbar("Error", "Failed to create story");
    } finally {
      isLoading.value = false;
    }
  }

  /*Future<void> createHighlight() async {
    try {
      isLoading.value = true;

      List<File> mediaFiles = [];

      if (imageFile.value != null) {
        mediaFiles.add(imageFile.value!);
      } else if (videoFile.value != null) {
        mediaFiles.add(videoFile.value!);
      }

      Map<String, dynamic> body = {
        "title": captionCtrl.text,
      };

      // Backend usually expects: media[] instead of media[0]
      for (int i = 0; i < mediaFiles.length; i++) {
        body["cover_media"] = mediaFiles[i];
      }

      print("createhighlightRequest : $body");

      final response = await api.callPost(
        "api/v1/stories/highlights",
        data: body,
        isFormData: true,
      );

      print("highlight RESPONSE: $response");

      if (response != null) {
        CustomSnackBar.showSuccess(message: '${response["message"]}');
        Get.back();
      }

    } catch (e) {
      print("POST ERROR: $e");
      Get.snackbar("Error", "Failed to create story");
    } finally {
      isLoading.value = false;
    }
  }*/


  Future<void> createHighlight() async {
    try {
      isLoading.value = true;

      // Ye list ek bhi id ho sakti hai ya multiple
      List<int> storyIds = [currentStoryId]; // e.g. [123] OR [123, 456]

      Map<String, dynamic> body = {
        "title": captionCtrl.text.isEmpty ? "Highlight" : captionCtrl.text,

      };

      // 👉 OPTIONAL cover_media (image/video)
      if (imageFile.value != null) {
        body["cover_media"] = await MultipartFile.fromFile(
          imageFile.value!.path,
          filename: imageFile.value!.path.split("/").last,
        );
      } else if (videoFile.value != null) {
        body["cover_media"] = await MultipartFile.fromFile(
          videoFile.value!.path,
          filename: videoFile.value!.path.split("/").last,
        );
      }

      // 👉 STORY IDs ko array format me send karna (1 ho ya 10 ho)
      for (int i = 0; i < storyIds.length; i++) {
        body["story_ids[$i]"] = storyIds[i].toString();
      }

      print("Final Request Body => $body");

      final response = await api.callPost(
        "api/v1/stories/highlights",
        data: body,
        isFormData: true,
      );

      print("Highlight Response => $response");

      if (response != null) {
        CustomSnackBar.showSuccess(message: response["message"]);
        Get.back();
      }

    } catch (e) {
      print("Create highlight error: $e");
      Get.snackbar("Error", "Failed to create highlight");
    } finally {
      isLoading.value = false;
    }
  }

  void showMoreOption() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30), // 👈 beautiful curved top
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOP small gray divider
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 20),

            // Delete
            ListTile(
            //  leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                "Delete",
                style: TextStyle(color: AppColors.error,fontWeight:FontWeight.bold ),
              ),
              onTap: () {
                Get.back(closeOverlays: true);
                deleteHighlight(currentStoryId);
              },
            ),

            // Highlight
            ListTile(
         //     leading: const Icon(Icons.star, color: Colors.black),
              title: const Text(
                "Highlight",
                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Get.back(closeOverlays: true);
                addToHighlight();
                // Get.back();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void addToHighlight() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30), // 👈 beautiful curved top
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOP small gray divider
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 20),
            Text("Add to highlights",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 20),),

            const SizedBox(height: 20),

            Obx(() {
              if (controller.isLoading.value) {
                return SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount:
                  controller.highlights.length + 1,
                  itemBuilder: (context, index) {
                    // Add Story Button
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () {
                          Get.back(closeOverlays: true);
                          createNewHighlight();

                          // Get.to(() => FullScreenStoryViewer(
                          //   stories: controller.storyData,   // list jo aap pass karoge
                          //   initialIndex: index,      // kis story se start karni
                          // ));
                          //  storyController.showPickerOptions();
                        },

                        child: StoryWidgets.addStory(),
                      );
                    }

                    // Story item
                    final storyIndex = index - 1;

                    if (storyIndex >=
                        controller.highlights.length) {
                      return SizedBox(); // Safety
                    }

                    final story =
                    controller
                        .highlights[storyIndex];

                    return GestureDetector(
                      onTap: () {
                        // if (story.stories.isEmpty) {
                        //   Get.snackbar(
                        //     "No Highlights",
                        //     "Highlights not added yet.",
                        //     snackPosition:
                        //     SnackPosition.BOTTOM,
                        //   );
                        //   return;
                        // }
                        final highlightId = story.id;
                        Get.back(closeOverlays: true);
                        addStoryToHighlight(
                          highlightId: highlightId,
                          storyId: currentStoryId,
                        );
                      },
                      child: StoryWidgets.storyItem(
                       name: story.title,
                        imageUrl: story.cover_media_url,
                      ),
                    );
                  },
                ),
              );
            }),

          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> addStoryToHighlight({
    required int highlightId,
    required int storyId,
  }) async {
    try {
      isLoading.value = true;

      String apiUrl = "api/v1/stories/highlights/$highlightId/$storyId";

      print("Calling addStoryToHighlight: $apiUrl");

      final response = await api.callPost(
        apiUrl,
        data: {},
        isFormData: false,
      );

      print("API RESULT  addStoryToHighlight: $response");

      if (response != null && response["success"] == true) {
        Get.back();
        Get.back();

        CustomSnackBar.showSuccess(message: "Story added to highlight");

      } else {
        CustomSnackBar.showError(message: "Could not add story");

      }

    } catch (e) {
      print("AddToHighlight ERROR: $e");

      CustomSnackBar.showError(message: "Something went wrong");

    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteStory(int storyId) async {
    try {
      final response = await api.callDelete("api/v1/stories/$storyId");

      print("Delete Comment Response: $response");

      if (response == null) return false;

      final msg = response["message"] ?? "";

      final status = response["success"] == true;

      if (status) {

        homeController.removeStory(storyId);

        CustomSnackBar.showSuccess(message: "Story removed successfully" );
        return true;   // API success
      } else {
        Get.snackbar(
          "Error",
          msg,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }


  Future<bool> deleteHighlight(int storyId) async {
    try {
      final response = await api.callDelete("api/v1/stories/highlights/$currentHighlightId/$currentStoryId");

      print("Delete Comment Response: $response");

      if (response == null) return false;

      final msg = response["message"] ?? "";

      final status = response["success"] == true;

      if (status) {

        homeController.removeStory(storyId);
      //  controller.fetchHighlightes();

        CustomSnackBar.showSuccess(message: "Story removed successfully" );
        return true;   // API success
      } else {
        Get.snackbar(
          "Error",
          msg,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }


  void createNewHighlight() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TOP small gray divider
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 20),
            Text("Add to highlights",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 20),),

            const SizedBox(height: 20),
            StoryWidgets.addStory(),

            TextField(
                  controller: captionCtrl,
                textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: "Highlight",
                    hintStyle: TextStyle(
                      color: AppColors.darkTextPrimary,
                    ),
                    border: InputBorder.none,
                  ),
                ),


            InkWell(
              onTap: (){
                createHighlight();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  //borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Add",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // MyButton(title: "Add",onPressed: (){
            //   createHighlight();
            // },)

          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }


  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }


  Future<void> createComment({required int storyId, required String body}) async {
    try {
      isLoading.value = true;

      final response = await api.callPost(
        "api/v1/comments/story/$storyId",
        data: {
          "body": body,
        },
      );

      print("Create Comment Response: $response");

      if (response != null && response["data"] != null) {
        // Optionally add the newly created comment to the list
      //  commentsList.insert(0, CommentModel.fromJson(response["data"]));

      //  homeController.updateCommentCount(postId, true);

      }
    } catch (e) {
      print("Create Comment Error: $e");
    } finally {
      isLoading.value = false;
    }
  }



}
