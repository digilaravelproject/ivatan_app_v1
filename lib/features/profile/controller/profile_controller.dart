
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

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final String userName;

  ProfileController(this.userName);

  Rx<File?> imageFile = Rx<File?>(null);
  Rx<File?> videoFile = Rx<File?>(null);
  RxBool isVideoInitialized = false.obs;
  RxString videoUrl = "".obs;

  RxList<HighlightStoryModel> highlights = <HighlightStoryModel>[].obs;
  final HomeController homeController = Get.put(HomeController());
  final PostController = Get.put(OwnPostController(filterType: "posts", UserName: SharedPrefManager().user!.username));


  @override
  void onInit() {
    super.onInit();
    fetchHighlightes(userName);
  }


  VideoPlayerController? videoController;
  final ApiServices api = ApiServices();


  // ------------------ FORM FIELDS ---------------------
  RxString selectedType = "post".obs;
  RxString selectedVisibility = "public".obs;
  TextEditingController captionCtrl = TextEditingController();

  RxBool isLoading = false.obs;

  // --------------- PICK MEDIA (YOUR OWN LOGIC CALL HERE) ---------------------
  void setImage(File file) {
    imageFile.value = file;
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
     // Get.to(() => PreviewScreen());
      Get.to(() => PreviewScreen(userName: userName));

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

      Get.to(() => PreviewScreen(userName: userName));

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
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Pick Image from Gallery"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Capture Image"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text("Pick Video from Gallery"),
              onTap: () => pickVideo(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text("Record Video"),
              onTap: () => pickVideo(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> createPost() async {
    try {
      isLoading.value = true;

      List<File> mediaFiles = [];

      if (imageFile.value != null) {
        mediaFiles.add(imageFile.value!);
      } else if (videoFile.value != null) {
        mediaFiles.add(videoFile.value!);
      }

      Map<String, dynamic> body = {
        "type": selectedType.value,
        "caption": captionCtrl.text,
        "visibility": selectedVisibility.value,
      };

      for (int i = 0; i < mediaFiles.length; i++) {
        body["media[$i]"] = mediaFiles[i];
      }

      print("craetepostrequest : "+body.toString());

      final response = await api.callPost(
        "api/v1/posts",
        data: body,
        isFormData: true,
      );
      PostController.fetchOwnPosts();
      homeController.fetchPosts();
      print("POST RESPONSE: $response");


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


