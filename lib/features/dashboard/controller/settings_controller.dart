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
import '../../profile/screen/bookmarks_screen.dart';
import '../../../../core/helper/profile_permission_manager.dart' as ppm;

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
      AppUrls.updateProfile,
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
import '../../auth/data/model/res/profile_type_model.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../model/user_profile.dart';
import 'follow_controller.dart';
import '../../profile/controller/ownpostController.dart';
import 'homeController.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../../subscription/persentation/profile_plans_screen.dart';
import '../../subscription/data/model/profile_switch_request.dart';


class SettingsController extends GetxController {
  final String userName;

  SettingsController({required this.userName});

  final FollowController followController = Get.put(FollowController());

  RxBool isPrivate = false.obs;
  RxBool isLoading = false.obs;
  Rx<UserData?> userProfile = Rx<UserData?>(null);
  RxString contactVisibility = 'both'.obs; // 'both', 'phone', 'email', 'none'
  RxBool isEmployer = false.obs;
  RxBool isSeller = false.obs;
  var switchRequests = <ProfileSwitchRequest>[].obs;
  var isLoadingSwitchRequests = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final occupationController = TextEditingController();
  final bioController = TextEditingController();
  final languageController = TextEditingController();
  final pageCategoryController = TextEditingController();


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

  RxList<String> pageCategoryList = <String>[
    "profile subscription",
    "content creator",
    "business store pages",
    "business service pages",
    "music pages",
  ].obs;

  RxString selectedPageCategory = "".obs;

  RxList<ProfileType> profileTypes = <ProfileType>[].obs;
  Rx<ProfileType?> selectedProfileType = Rx<ProfileType?>(null);
  RxString selectedSellerType = "".obs;

  final profileTypeController = TextEditingController();
  final sellerTypeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    profileTypes.value = _fallbackProfileTypes
        .map((json) => ProfileType.fromJson(json))
        .toList();
    fetchProfileTypes();
    fetchProfileSwitchRequests();

    String finalUserName = userName.isNotEmpty ? userName : (SharedPrefManager().user?.username ?? "");

    fetchUserDetails(finalUserName);
  }

  Future<void> fetchProfileTypes() async {
    try {
      final response = await api.callGet(AppUrls.profileTypes);
      if (response != null && response["status"] == true) {
        final List<dynamic> typesJson = response["data"]["types"];
        profileTypes.value = typesJson.map((x) => ProfileType.fromJson(x)).toList();
        
        // Re-run matching after profile types are fetched from API
        _matchProfileType();
      }
    } catch (e) {
      print("⚠️ Silent background fetch of profile types failed: $e");
    }
  }

  Future<void> fetchProfileSwitchRequests() async {
    try {
      isLoadingSwitchRequests.value = true;
      final response = await api.callGet(AppUrls.profileSwitchRequests);
      if (response != null && response["status"] == true) {
        final rawData = response["data"];
        if (rawData != null && rawData["switch_requests"] is List) {
          final List<dynamic> requestsJson = rawData["switch_requests"];
          switchRequests.value = requestsJson.map((x) => ProfileSwitchRequest.fromJson(x)).toList();
        }
      }
    } catch (e) {
      print("⚠️ Error fetching profile switch requests: $e");
    } finally {
      isLoadingSwitchRequests.value = false;
    }
  }

  void showAdminApprovalDialog(String profileName) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: Color(0xFFD97706),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Awaiting Admin Approval",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Switching to $profileName does not require any subscription. Your request is currently pending review by the admin team.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Okay",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _fallbackProfileTypes = [
    {
      "type": "personal",
      "label": "Personal Profile",
      "description": "Default personal profile with basic features.",
      "is_default": true,
      "requires_approval": false,
      "has_subscription": true
    },
    {
      "type": "employer",
      "label": "Employer Profile",
      "description": "Post job openings and manage recruitment.",
      "is_default": false,
      "requires_approval": true,
      "has_subscription": false
    },
    {
      "type": "ecommerce",
      "label": "Ecommerce Profile",
      "description": "Sell products, services, or both.",
      "is_default": false,
      "requires_approval": true,
      "has_subscription": true,
      "sub_types": [
        "product",
        "service",
        "both"
      ]
    },
    {
      "type": "music",
      "label": "Music Playlist Profile",
      "description": "Create and manage music playlists.",
      "is_default": false,
      "requires_approval": true,
      "has_subscription": false
    },
    {
      "type": "creator",
      "label": "Content Creator Profile",
      "description": "Upload content, manage monetization.",
      "is_default": false,
      "requires_approval": true,
      "has_subscription": true
    }
  ];

  void _matchProfileType() {
    String? userProfileType = ppm.ProfilePermissionManager.currentProfileName?.toLowerCase();
    
    if (userProfileType == null || userProfileType.isEmpty) {
      userProfileType = userProfile.value?.profileType?.toLowerCase();
    }

    // Normalize type strings to match backend/controller types
    if (userProfileType == 'ecommerce') {
      userProfileType = 'seller';
    } else if (userProfileType == 'music_play') {
      userProfileType = 'music';
    } else if (userProfileType == 'content_creation') {
      userProfileType = 'creator';
    }

    String? userProfileSubType = ppm.ProfilePermissionManager.ecommerceSubType;
    if (userProfileSubType == null || userProfileSubType.isEmpty) {
      userProfileSubType = userProfile.value?.profileSubType;
    }

    if (userProfileType != null && userProfileType.isNotEmpty) {
      final matchedType = profileTypes.firstWhereOrNull((e) => e.type == userProfileType);
      if (matchedType != null) {
        selectedProfileType.value = matchedType;
        // For any type that has subtypes, show the selected subtype in the controller label
        if (userProfileSubType != null && userProfileSubType.isNotEmpty) {
          selectedSellerType.value = userProfileSubType;
          profileTypeController.text = "${matchedType.label} (${userProfileSubType.capitalizeFirst ?? userProfileSubType})";
          sellerTypeController.text = userProfileSubType;
        } else {
          profileTypeController.text = matchedType.label;
          sellerTypeController.clear();
        }
        return;
      }
    }

    if (isSeller.value) {
      final sellerType = profileTypes.firstWhereOrNull((e) => e.type == "seller");
      selectedProfileType.value = sellerType;
      profileTypeController.text = sellerType?.label ?? "";
    } else if (isEmployer.value) {
      final employerType = profileTypes.firstWhereOrNull((e) => e.type == "employer");
      selectedProfileType.value = employerType;
      profileTypeController.text = employerType?.label ?? "";
    } else {
      final personalType = profileTypes.firstWhereOrNull((e) => e.type == "personal");
      selectedProfileType.value = personalType;
      profileTypeController.text = personalType?.label ?? "";
    }
  }


  Future<void> switchProfileType(ProfileType profileType, String sellerType) async {
    try {
      isLoading.value = true;

      // Map UI types to Backend/API expected strings
      String apiProfileType = profileType.type;
      if (apiProfileType == 'personal') {
        apiProfileType = 'personal_profile';
      } else if (apiProfileType == 'seller') {
        apiProfileType = 'ecommerce';
      } else if (apiProfileType == 'music') {
        apiProfileType = 'music_play';
      } else if (apiProfileType == 'creator') {
        apiProfileType = 'content_creation';
      }

      final String? apiProfileSubType = sellerType.isNotEmpty ? sellerType : null;

      final Map<String, dynamic> body = {
        "to_profile_type": apiProfileType,
        "notes": "I want to switch to $apiProfileType.",
      };
      if (apiProfileSubType != null) {
        body["profile_sub_type"] = apiProfileSubType;
      }

      final response = await api.callPost(
        AppUrls.profileSwitch,
        data: body,
      );

      if (response != null && response["status"] == true) {
        selectedProfileType.value = profileType;
        selectedSellerType.value = sellerType;

        if (profileType.type == 'seller') {
          isSeller.value = true;
          isEmployer.value = false;
        } else if (profileType.type == 'employer') {
          isSeller.value = false;
          isEmployer.value = true;
        } else {
          isSeller.value = false;
          isEmployer.value = false;
        }

        // Update text label — show subtype in parentheses for any type that has one
        if (sellerType.isNotEmpty) {
          profileTypeController.text = "${profileType.label} (${sellerType.capitalizeFirst ?? sellerType})";
          sellerTypeController.text = sellerType;
        } else {
          profileTypeController.text = profileType.label;
          sellerTypeController.clear();
        }

        Get.snackbar(
          "Success",
          response["message"] ?? "Switch request submitted successfully.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        fetchUserDetails(userName.isNotEmpty ? userName : (SharedPrefManager().user?.username ?? ""));
        fetchProfileSwitchRequests();

        // Fetch subscription plans dynamically and navigate to ProfilePlansScreen ONLY if required
        final toType = profileType.type;
        final subType = apiProfileSubType;

        bool isFreeFlow = toType == 'employer' || 
            (toType == 'seller' && (subType == 'product' || subType == 'service'));

        if (isFreeFlow) {
          showAdminApprovalDialog(profileType.label);
        } else {
          try {
            final subscriptionController = Get.isRegistered<SubscriptionController>()
                ? Get.find<SubscriptionController>()
                : Get.put(SubscriptionController());
            final updatedSub = await subscriptionController.fetchPlansForProfileType(profileType.type);
            if (updatedSub != null) {
              Get.to(() => ProfilePlansScreen(profileTypeSub: updatedSub));
            }
          } catch (e) {
            print("⚠️ Error loading plans: $e");
          }
        }
      } else {
        Get.snackbar(
          "Error",
          response != null ? (response["message"] ?? "Switch failed") : "Switch failed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("❌ SWITCH PROFILE ERROR: $e");
      Get.snackbar(
        "Error",
        "Something went wrong: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
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

      request.fields["page_category"] = selectedPageCategory.value.isNotEmpty
          ? selectedPageCategory.value
          : (userProfile?.value?.pageCategory ?? "");


      request.fields["gender"] = staticGender;
      request.fields["password"] = staticPassword;
      request.fields["date_of_birth"] = staticDob;


      request.fields["account_privacy"] = isPrivate.value ? "private" : "public";
      request.fields["contact_visibility"] = contactVisibility.value;


      request.fields["messaging_privacy"] = staticMessagingPrivacy;

      // Employer and Seller values
      request.fields["is_employer"] = isEmployer.value ? "1" : "0";
      request.fields["is_seller"] = isSeller.value ? "1" : "0";

      // Profile Type and Sub Type
      // Send exactly what the API returned — no custom mapping
      final String? apiProfileType = selectedProfileType.value?.type;
      final String? apiProfileSubType = selectedSellerType.value.isNotEmpty
          ? selectedSellerType.value
          : null;

      if (apiProfileType != null) {
        request.fields["profile_type"] = apiProfileType;
      }
      if (apiProfileSubType != null) {
        request.fields["profile_sub_type"] = apiProfileSubType;
      }

      // Interests array
      // final interests = userProfile.value?.interests ?? [];
      // for (int i = 0; i < interests.length; i++) {
      //   request.fields["interests[$i]"] = interests[i]["id"].toString();
      // }


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

      // 4️⃣ Sync with Profile View Tabs (MyPostScreen, MyVideoScreen, etc.)
      final List<String> filters = ["posts", "videos"];
      for (var filter in filters) {
        final tag = "${userName}_$filter";
        if (Get.isRegistered<OwnPostController>(tag: tag)) {
          final ownPostController = Get.find<OwnPostController>(tag: tag);
          ownPostController.fetchOwnPosts(username: userName, filterType: filter);
        }
      }
      
      // Also sync ProfileLivePosts (which uses raw username as tag)
      if (Get.isRegistered<OwnPostController>(tag: userName)) {
         final livePostController = Get.find<OwnPostController>(tag: userName);
         livePostController.fetchOwnPosts(username: userName, filterType: "posts");
      }
      
    } catch (e) {
      print("Follow Error: $e");
    }
  }

  Future<void> toggleBlockUser(int userId) async {
    try {
      isLoading.value = true;
      final response = await api.callPost(AppUrls.blockUser(userId), data: {});
      isLoading.value = false;

      if (response != null && response['success'] == true) {
        bool blocked = response['is_blocked'] ?? false;
        
        // Update local state if we are viewing this user's profile
        if (userProfile.value?.id == userId) {
          userProfile.value = UserData.fromJson({
            ...userProfile.value!.toJson(),
            "is_blocked": blocked,
          });
          userProfile.refresh();
        }

        CustomSnackBar.showSuccess(
          message: response['message'] ?? (blocked ? "User blocked" : "User unblocked")
        );

        // If blocked, we might want to refresh the feed or go back
        if (blocked) {
          // Clear posts from this user in feeds
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().posts.removeWhere((p) => p.user.id == userId);
            Get.find<HomeController>().posts.refresh();
          }
          // If on their profile, we might stay to show "Blocked" state or go back
          // User requested "Block" option in 3-dot, so we'll stay and refresh.
          fetchUserDetails(userProfile.value?.username ?? "");
        }
      }
    } catch (e) {
      isLoading.value = false;
      print("Block Error: $e");
      CustomSnackBar.showError(message: "Failed to update block status");
    }
  }

  void openBookmarks() {
    Get.to(() => const BookmarksScreen());
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
      isLoading.value = true;
      print("fetchuserdetails for: $userName");

      final result = await getUserDetails(userName);
      
      if (result != null) {
        print("fetchuserdetails success: ${result.user?.username}");
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
        pageCategoryController.text = result.user!.pageCategory ?? "";
        selectedPageCategory.value = result.user!.pageCategory ?? "";
        selectedOccupation.value = result.user!.occupation ?? "";
        bioController.text = result.user!.bio ?? "";
        languageController.text = result.user!.languagePreference ?? "en";
        isPrivate.value = result.user!.accountPrivacy == "private";
        contactVisibility.value = result.user!.contactVisibility ?? 'both';
        isEmployer.value = ppm.ProfilePermissionManager.isProfileActive(ppm.ProfileType.employer);
        isSeller.value = ppm.ProfilePermissionManager.isProfileActive(ppm.ProfileType.ecommerce);
        _matchProfileType();
        
        // SYNC FOLLOW STATUS
        if (result.user?.id != null) {
          followController.setInitialFollowStatus(result.user!.id!, result.user!.is_following ?? false);
        }
      } else {
        print("fetchuserdetails: result is null");
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
    final response = await api.callGet(AppUrls.userProfileUrl(username), showErrorToast: false);

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



