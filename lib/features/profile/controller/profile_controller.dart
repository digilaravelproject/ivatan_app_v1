
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/features/profile/controller/profile_controller.dart' as _picker;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

/*class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  var imageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        File original = File(pickedFile.path);
        File? compressed = await compressImage(original);

        if (compressed != null) {
          imageFile.value = compressed;
        } else {
          imageFile.value = original;
        }

        print("📦 Final Image Size: ${imageFile.value!.lengthSync() / 1024} KB");
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }


  void showPickerOptions() {
    Get.bottomSheet(
      Container(
        color: const Color(0xFFf9f9f9),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                pickImage(ImageSource.camera);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<File?> compressImage(File file) async {
    final filePath = file.path;

    // Output path manually create
    final outPath = "${filePath}_compressed.jpg";

    XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedXFile == null) {
      print("❌ Compression failed, returning original image");
      return file;
    }

    // Convert XFile → File
    File compressedFile = File(compressedXFile.path);

    double sizeKB = compressedFile.lengthSync() / 1024;
    print("📉 COMPRESSED SIZE 1: ${sizeKB.toStringAsFixed(2)} KB");

    // Again compress if still too large
    if (sizeKB > 2048) {
      final outPath2 = "${filePath}_compressed2.jpg";

      XFile? compressedXFile2 = await FlutterImageCompress.compressAndGetFile(
        compressedFile.path,
        outPath2,
        quality: 50,
        minWidth: 600,
        minHeight: 600,
      );

      if (compressedXFile2 != null) {
        File compressedAgain = File(compressedXFile2.path);
        print("📉 COMPRESSED SIZE 2: ${compressedAgain.lengthSync() / 1024} KB");
        return compressedAgain;
      }
    }

    return compressedFile;
  }

}*/

import 'package:video_player/video_player.dart';
import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../../dashboard/controller/homeController.dart';
import '../model/storyHighlight.dart';
import '../screen/postPreviewImage.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

import 'package:http/http.dart' as http;

import 'ownpostController.dart';
import '../../dashboard/controller/create_story_controller.dart';
import '../../dashboard/persentation/createStoryScreen.dart';

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final String userName;

  ProfileController(this.userName);

  Rx<File?> imageFile = Rx<File?>(null);
  RxList<File> imageFiles = <File>[].obs;
  Rx<File?> videoFile = Rx<File?>(null);
  RxBool isVideoInitialized = false.obs;
  RxString videoUrl = "".obs;

  RxList<HighlightStoryModel> highlights = <HighlightStoryModel>[].obs;
  final HomeController homeController = Get.put(HomeController());
  final PostController = Get.put(OwnPostController(filterType: "posts", UserName: SharedPrefManager().user!.username));


  VideoPlayerController? videoController;
  final ApiServices api = ApiServices();

  // ------------------ FORM FIELDS ---------------------
  RxString selectedType = "post".obs;
  RxString selectedVisibility = "public".obs;
  TextEditingController captionCtrl = TextEditingController();
  TextEditingController titleCtrl = TextEditingController();
  
  // For reactive validation
  RxString currentCaption = "".obs;
  RxString currentTitle = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchHighlightes(userName);
    
    // Listen to controllers for reactive UI updates
    captionCtrl.addListener(() {
      currentCaption.value = captionCtrl.text;
    });
    titleCtrl.addListener(() {
      currentTitle.value = titleCtrl.text;
    });
  }

  RxBool isLoading = false.obs;

  // --------------- PICK MEDIA (YOUR OWN LOGIC CALL HERE) ---------------------
  void setImage(File file) {
    imageFile.value = file;
    videoFile.value = null;
  }

  // ------------------ IMAGE CROPPER ---------------------
  Future<void> cropImage() async {
    if (imageFile.value == null || isLoading.value) return;

    try {
      isLoading.value = true;
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.value!.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Photo',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.blue,
          ),
          IOSUiSettings(
            title: 'Edit Photo',
          ),
        ],
      );

      if (croppedFile != null) {
        imageFile.value = File(croppedFile.path);
        // If it's a carousel, update the first item (or current)
        if (imageFiles.isNotEmpty) {
           imageFiles[0] = imageFile.value!;
        }
      }
    } catch (e) {
      print("Crop error: $e");
    } finally {
      isLoading.value = false;
    }
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
      imageFiles.clear();
      imageFiles.add(imageFile.value!);
      videoFile.value = null;
      videoUrl.value = "";
      
      // Route to StoryScreen for story type, otherwise PreviewScreen
      if (selectedType.value == "story") {
        final storyController = Get.put(StoryController());
        storyController.imageFile.value = imageFile.value;
        Get.to(() => StoryScreen());
      } else {
        Get.to(() => PreviewScreen(userName: userName));
      }

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

      final file = File(picked.path);
      videoFile.value = file;
      videoUrl.value = file.path;
      imageFile.value = null;
      imageFiles.clear();
      print("Video ready (Deferred Compression): ${videoUrl.value}");

      // Initialize controller
      videoController?.dispose();
      videoController = VideoPlayerController.file(videoFile.value!);

      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.play();
      isVideoInitialized.value = true;

      // Route to StoryScreen for story type, otherwise PreviewScreen
      if (selectedType.value == "story") {
        final storyController = Get.put(StoryController());
        storyController.videoFile.value = videoFile.value;
        storyController.videoController = videoController;
        storyController.isVideoInitialized.value = true;
        Get.to(() => StoryScreen());
      } else {
        Get.to(() => PreviewScreen(userName: userName));
      }

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


  void showPickerOptions() {
    // Determine media type based on selectedType
    final bool isImageType = selectedType.value == "post" || selectedType.value == "carousel";
    final bool isVideoType = selectedType.value == "reel" || selectedType.value == "video";
    final bool isStoryType = selectedType.value == "story";

    Get.bottomSheet(
      Container(
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
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                isStoryType ? "Add to Story" : (isImageType ? "Add Photo" : "Add Video"),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Show image options for posts and stories
            if (isImageType || isStoryType) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text("Choose from Gallery"),
                subtitle: const Text("Select photos from your device"),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: const Text("Take Photo"),
                subtitle: const Text("Capture a new photo"),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.camera);
                },
              ),
            ],
            
            // Show video options for reels and stories
            if (isVideoType || isStoryType) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.video_library, color: Colors.purple),
                ),
                title: const Text("Choose Video from Gallery"),
                subtitle: const Text("Select videos from your device"),
                onTap: () => pickVideo(ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam, color: Colors.red),
                ),
                title: const Text("Record Video"),
                subtitle: const Text("Capture a new video"),
                onTap: () => pickVideo(ImageSource.camera),
              ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Future<void> createPost() async {
    try {
      isLoading.value = true;
      CustomSnackBar.showInfo(message: "Sharing your post, please wait...");

      List<File> mediaFiles = [];

      if (imageFiles.isNotEmpty) {
        mediaFiles.addAll(imageFiles);
      } else if (imageFile.value != null) {
        mediaFiles.add(imageFile.value!);
      } else if (videoFile.value != null) {
        mediaFiles.add(videoFile.value!);
      }

      String apiType = selectedType.value;
      
      // Auto-determine carousel/post if not explicitly set to video/reel
      if (apiType == 'post' || apiType == 'carousel') {
        if (mediaFiles.length > 1) {
          apiType = 'carousel';
        } else {
          apiType = 'post';
        }
      }
      final caption = captionCtrl.text.trim();
      final title = titleCtrl.text.trim();
      
      Map<String, dynamic> body = {
        "type": apiType,
        "caption": caption,
        "title": title.isEmpty ? caption : title,
        "description": caption,
        "visibility": selectedVisibility.value,
      };

      // Backend expects media[] ALWAYS to be an array for posts
      body["media[]"] = mediaFiles;

      print("craetepostrequest : "+body.toString());

      // Start background upload
      homeController.uploadMediaInBackground("api/v1/posts", body);

      // Navigate back to Profile immediately
      Get.back();

      // Clear all state for next time
      captionCtrl.clear();
      titleCtrl.clear();
      imageFiles.clear();
      imageFile.value = null;
      videoFile.value = null;
      isVideoInitialized.value = false;
      if (videoController != null) {
        videoController!.dispose();
        videoController = null;
      }
      
      CustomSnackBar.showInfo(message: "Sharing your post in background...");

    } catch (e) {
      print("POST ERROR: $e");
      CustomSnackBar.showError(message: "Failed to start upload: $e");
    } finally {
      isLoading.value = false;
    }
  }


/*
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
       // "type": selectedType.value,
        "caption": captionCtrl.text,
      //  "visibility": selectedVisibility.value,
      };

      for (int i = 0; i < mediaFiles.length; i++) {
        body["media[$i]"] = mediaFiles[i];
      }

      print("craetepostrequest : "+body.toString());

      final response = await api.callPost(
        "api/v1/stories",
        data: body,
        isFormData: true,
      );

      print("story RESPONSE: $response");

      if (response != null) {
        CustomSnackBar.showSuccess(message: '${response["message"]}');
        Get.back();
      }

    } catch (e) {
      print("POST ERROR: $e");
      Get.snackbar("Error", "Failed to create post");
    } finally {
      isLoading.value = false;
    }
  }
*/


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

      body["media[]"] = mediaFiles;

      print("createStoryRequest : $body");

      final response = await api.callPost(
        "api/v1/stories",
        data: body,
        isFormData: true,
      );

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


  Future<void> fetchHighlightes(String userName) async {
    isLoading.value = true;

    final response = await api.callGet("api/v1/stories/highlights/user/$userName");

    print("fetchHighlightes : "+response.toString());

    if (response != null && response["data"] != null) {
      highlights.value = List<HighlightStoryModel>.from(
        response["data"].map((e) => HighlightStoryModel.fromJson(e)),
      );
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }




}


