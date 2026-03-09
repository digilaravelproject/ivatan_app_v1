import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:i_vatan_app/features/profile/screen/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../profile/screen/avatar_customizer_screen.dart';

/*
class ProfileController extends GetxController {
  RxBool isPrivate = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final occupationController = TextEditingController();
  final bioControllerer = TextEditingController();
  final languageController = TextEditingController();

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (value.length < 3) return "Enter at least 3 characters";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(value.trim())) {
      return "Enter valid email";
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return "Username required";
    if (value.length < 3) return "Enter at least 3 characters";
    return null;
  }



  var imageFile = Rx<File?>(null); // reactive variable

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
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


}
*/




/*import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';

class ProfileController extends GetxController {
  /// -----------------------
  /// ONLY USED TOGGLE
  /// -----------------------
  RxBool isPrivate = false.obs;
  final ApiServices api = Get.put(ApiServices());

  /// -----------------------
  /// TEXT CONTROLLERS
  /// -----------------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final languageController = TextEditingController();

  /// Static values for now
  String staticGender = "male";
  String staticPassword = "Abcd@123";
  String staticDob = "1990-05-15";
  String staticMessagingPrivacy = "everyone";

  /// -----------------------
  /// IMAGE PICKER
  /// -----------------------
  final ImagePicker _picker = ImagePicker();
  var imageFile = Rx<File?>(null);

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
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

  /// -----------------------
  /// UPDATE PROFILE API
  /// -----------------------
 *//* Future<void> updateProfile() async {
    final uri = Uri.parse("https://www.ivatan.in/api/v1/auth/update");

    var request = http.MultipartRequest("POST", uri);

    /// HEADERS (TOKEN + ACCEPT ONLY)
    request.headers["Authorization"] = "Bearer ${SharedPrefManager().token ?? AppUrls.defaultApiKey}";
    request.headers["Accept"] =  "application/json";

    /// -------------------------
    /// ADD FIELDS
    /// -------------------------
    request.fields["name"] = nameController.text;
    request.fields["email"] = emailController.text;
    request.fields["phone"] = phoneController.text;
    request.fields["username"] = usernameController.text;
    request.fields["occupation"] = occupationController.text;
    request.fields["bio"] = bioController.text;
    request.fields["language_preference"] = languageController.text;

    // Static
    request.fields["gender"] = staticGender;
    request.fields["password"] = staticPassword;
    request.fields["date_of_birth"] = staticDob;

    // Toggle → public / private
    request.fields["account_privacy"] = isPrivate.value ? "private" : "public";

    // Static
    request.fields["messaging_privacy"] = staticMessagingPrivacy;

    // Static interest list for now
    List<String> interests = [
      "Web Development",
      "App Development",
      "Flutter",
    ];

    for (int i = 0; i < interests.length; i++) {
      request.fields["interests[$i]"] = interests[i];
    }

    /// -------------------------
    /// ADD IMAGE IF SELECTED
    /// -------------------------
    if (imageFile.value != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_photo",
          imageFile.value!.path,
        ),
      );
    }

    /// -------------------------
    /// SEND REQUEST
    /// -------------------------
    try {
      http.StreamedResponse response = await request.send();
      String body = await response.stream.bytesToString();

      print("📌 STATUS: ${response.statusCode}");
      print("📌 RESPONSE: $body");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Profile Updated Successfully");
      } else {
        Get.snackbar("Error", "Update Failed");
      }
    } catch (e) {
      print("API ERROR: $e");
      Get.snackbar("Error", "Something went wrong");
    }
  }*//*

  Future<void> updateProfile() async {
    Map<String, dynamic> payload = {
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "username": usernameController.text,
      "occupation": occupationController.text,
      "bio": bioController.text,
      "language_preference": languageController.text,

      // static fields
      "gender": staticGender,
      "password": staticPassword,
      "date_of_birth": staticDob,
      "messaging_privacy": staticMessagingPrivacy,

      // toggle
      "account_privacy": isPrivate.value ? "private" : "public",

      // interests[]
      "interests[0]": "Web Development",
      "interests[1]": "App Development",
      "interests[2]": "Flutter",
    };

    // image (if user selected)
    if (imageFile.value != null) {
      payload["profile_photo"] = imageFile.value!;
    }

    final result = await api.callPost(
      "api/v1/auth/update",
      data: payload,
      isFormData: true,
    );

    print("API RESULT: $result");

    if (result != null && result["status"] == true) {
      Get.snackbar("Success", "Profile Updated Successfully");
    } else {
      Get.snackbar("Error", "Update Failed");
    }
  }

}*/




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../../auth/data/model/res/user_model.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../model/user_profile.dart';
import 'follow_controller.dart';
import 'homeController.dart';

class SettingsController extends GetxController {
  final String userName;

  SettingsController({required this.userName});

  final FollowController followController = Get.put(FollowController());

  RxBool isPrivate = false.obs;
  RxBool isLoading = false.obs;
  Rx<UserData?> userProfile = Rx<UserData?>(null);
  RxString contactVisibility = 'both'.obs; // 'both', 'phone', 'email', 'none'

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final languageController = TextEditingController();


  String staticGender = "male";
  String staticPassword = "Abcd@123";
  String staticDob = "1990-05-15";
  String staticMessagingPrivacy = "everyone";

  final ApiServices api = ApiServices();
  final ImagePicker _picker = ImagePicker();
  var imageFile = Rx<File?>(null);

  RxList<String> occupationList = <String>[
    "Student / Learner",
    "Working Professional",
    "Freelancer / Flexible Employee",
    "Business Owner / Self-Employed",
    "Looking for Opportunities",
    "Others (Not Found! Any More creative.)",
  ].obs;

  RxString selectedOccupation = "".obs;

  @override
  void onInit() {
    super.onInit();

    String finalUserName = userName.isNotEmpty ? userName : (SharedPrefManager().user?.username ?? "");

    fetchUserDetails(finalUserName);

  }


  Future<void> updateProfile({bool shouldGoBack = true}) async {
    try {
      isLoading.value = true;

      // Get current user data
      // final user = SharedPrefManager().user;

      final uri = Uri.parse("${AppUrls.baseUrl}api/v1/auth/update");

      var request = http.MultipartRequest("POST", uri);


      request.headers["Authorization"] = "Bearer ${SharedPrefManager().token ?? AppUrls.defaultApiKey}";
      // request.headers["Accept"] = "multipart/form-data";
      request.headers["Accept"] = "application/json";
      request.headers["Content-Type"] = "multipart/form-data";


      request.fields["name"] = nameController.text.isNotEmpty
          ? nameController.text
          : (userProfile?.value?.name ?? "");

      request.fields["email"] = emailController.text.isNotEmpty
          ? emailController.text
          : (userProfile?.value?.email ?? "");

      request.fields["phone"] = phoneController.text.isNotEmpty
          ? phoneController.text
          : (userProfile?.value?.phone ?? "");

      request.fields["username"] = usernameController.text.isNotEmpty
          ? usernameController.text
          : (userProfile?.value?.username ?? "");

      request.fields["occupation"] = selectedOccupation.value.isNotEmpty
          ? selectedOccupation.value
          : (userProfile?.value?.occupation ?? "");

      request.fields["bio"] = bioController.text.isNotEmpty
          ? bioController.text
          : (userProfile?.value?.bio ?? "");

      request.fields["language_preference"] = languageController.text.isNotEmpty
          ? languageController.text
          : (userProfile?.value?.languagePreference ?? "en");


      request.fields["gender"] = staticGender;
      request.fields["password"] = staticPassword;
      request.fields["date_of_birth"] = staticDob;


      request.fields["account_privacy"] = isPrivate.value ? "private" : "public";
      request.fields["contact_visibility"] = contactVisibility.value;


      request.fields["messaging_privacy"] = staticMessagingPrivacy;

      // Interests array - Postman style
      // request.fields["interests[]"] = "Web Development";
      // request.fields["interests[]"] = "App Development";
      // request.fields["interests[]"] = "Flutter";


      if (imageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profile_photo",
            imageFile.value!.path,
          ),
        );
        print("📸 Image added: ${imageFile.value!.path}");
      }

      print("📤 SENDING REQUEST");
      print("📌 URL: ${uri.toString()}");
      print("📌 Fields: ${request.fields}");
      print("📌 Files: ${request.files.length}");
      print("📌 Headers: ${request.headers}");

      http.StreamedResponse response = await request.send();
      String body = await response.stream.bytesToString();

      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RESPONSE BODY: $body");

      isLoading.value = false;

      if (response.statusCode == 200) {

        final responseData = jsonDecode(body);


        // 1️⃣ updated user JSON निकालो
        final updatedUserJson = responseData["data"]["user"];

        // 2️⃣ SharedPref में updated user save करो (token को मत छुओ)
        await SharedPrefManager().updateUserOnly(updatedUserJson);

        // 3️⃣ UI refresh करने के लिए local UserModel भी reload कर लो
        final updatedUserModel = UserModel.fromJson({
          "user": updatedUserJson,
          "token": SharedPrefManager().token
        });

        // तुम चाहो तो controller में भी set कर सकती हो
        userProfile.value = UserData.fromJson(updatedUserJson);
        Get.find<HomeController>().refreshUser();


        if (shouldGoBack) {
          Get.back();
        }
        Get.snackbar(
          "Success",
          responseData["message"] ?? "Profile Updated Successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Clear image after successful update
        imageFile.value = null;

      } else {
        final responseData = jsonDecode(body);
        Get.snackbar(
          "Error",
          responseData["message"] ?? "Update Failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

    } catch (e) {
      isLoading.value = false;
      print("❌ API ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }


  Future<void> toggleFollowForPostUser(int userId) async {
    try {
      // Toggle follow through FollowController
      await followController.toggleFollow(userId);

      // 1️⃣ Sync with current ProfileScreen user
      if (userProfile.value?.id == userId) {
        // Refetch to get new counts (Followers/Following)
        await fetchUserDetails(userProfile.value?.username ?? "");
      } else {
        userProfile.value?.is_following = followController.isUserFollowing(userId).value;
        userProfile.refresh();
      }

      // 2️⃣ Sync with HomeController (Home Feed)
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        for (var post in homeController.posts) {
          if (post.user.id == userId) {
            post.is_following = followController.isUserFollowing(userId).value;
          }
        }
        homeController.posts.refresh();
      }

      // 3️⃣ Sync with PostController (Search/Trending Feed)
      if (Get.isRegistered<PostController>()) {
        final postController = Get.find<PostController>();
        
        // Sync trending posts
        for (var post in postController.posts) {
          if (post.user.id == userId) {
            post.isFollowing = followController.isUserFollowing(userId).value;
          }
        }
        postController.posts.refresh();

        // Sync interested posts
        for (var post in postController.intrestedPostList) {
          if (post.user.id == userId) {
            post.isFollowing = followController.isUserFollowing(userId).value;
          }
        }
        postController.intrestedPostList.refresh();
      }
      
    } catch (e) {
      print("Follow Error: $e");
    }
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle for aesthetics
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Select Profile Photo",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  color: Colors.blue,
                  onTap: () async {
                    print("📂 Picking from Gallery...");
                    Get.back();
                    await pickImage(ImageSource.gallery);
                    if (imageFile.value != null) {
                      print("✅ Photo picked, updating profile...");
                      updateProfile(shouldGoBack: false);
                    }
                  },
                ),
                _buildPickerOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  color: Colors.green,
                  onTap: () async {
                    print("📸 Picking from Camera...");
                    Get.back();
                    await pickImage(ImageSource.camera);
                    if (imageFile.value != null) {
                      print("✅ Photo captured, updating profile...");
                      updateProfile(shouldGoBack: false);
                    }
                  },
                ),
                _buildPickerOption(
                  icon: Icons.face_retouching_natural,
                  label: "Avatar",
                  color: Colors.purple,
                  onTap: () async {
                    print("🚀 Opening Avatar Customizer...");
                    Get.back();
                    var result = await Get.to(() => const AvatarCustomizerScreen());
                    print("📥 Avatar Customizer result: $result");
                    if (result is File) {
                      imageFile.value = result;
                      print("✅ Avatar selected, updating profile...");
                      updateProfile(shouldGoBack: false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> fetchUserDetails(String userName) async {
    try {
   //   isLoading.value = true;

      //String username = SharedPrefManager().user?.username ?? "";

      print("fetchuserdetails : "+userName);

      final result = await getUserDetails(userName);
      if (result == null) {
        // Get.snackbar(
        //   "User Not Found",
        //   "The user '$userName' does not exist or cannot be accessed.",
        //   snackPosition: SnackPosition.BOTTOM,
        // );
        return;
      }

      print("fetchuserdetails : "+result!.user.toString());

      if (result != null) {
        userProfile.value = result.user;
        // await SharedPrefManager().updateUserName(result.user!.name ?? "");
        //
        // await SharedPrefManager().updateUserProfilePhoto(result.user!.profilePhotoPath ?? "");
        // Get.find<HomeController>().refreshUser();

        nameController.text = result.user!.name ?? "";
        emailController.text = result.user!.email ?? "";
        phoneController.text = result.user!.phone ?? "";
        usernameController.text = result.user!.username ?? "";
        occupationController.text = result.user!.occupation ?? "";
        selectedOccupation.value = result.user!.occupation ?? "";
        bioController.text = result.user!.bio ?? "";
        languageController.text = result.user!.languagePreference ?? "en";
        isPrivate.value = result.user!.accountPrivacy == "private";
        contactVisibility.value = result.user!.contactVisibility ?? 'both';
        
        // SYNC FOLLOW STATUS
        if (result.user?.id != null) {
          followController.setInitialFollowStatus(result.user!.id!, result.user!.is_following ?? false);
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String? validateOccupation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please select occupation";
    }
    return null;
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

  Future<UserDetailsModel?> getUserDetails(String username) async {
    final response = await api.callGet("api/v1/users/$username", showErrorToast: false);

    print("getUserDetails : "+response!.values.toString());
    if (response == null) return null;

    return UserDetailsModel.fromJson(response);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    occupationController.dispose();
    bioController.dispose();
    languageController.dispose();
    super.onClose();
  }
}



