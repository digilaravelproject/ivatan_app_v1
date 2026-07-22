import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../data/model/blocked_user_model.dart';

class BlockedUsersController extends GetxController {
  var isLoading = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var blockedUsers = <BlockedUserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers({bool loadMore = false}) async {
    if (isLoading.value) return;
    if (loadMore && !hasMore.value) return;

    if (loadMore) {
      currentPage.value++;
    } else {
      currentPage.value = 1;
      blockedUsers.clear();
      hasMore.value = true;
    }

    isLoading.value = true;

    try {
      final token = SharedPrefManager().token;
      if (token == null) {
        isLoading.value = false;
        return;
      }

      final url = '${AppUrls.apiBaseUrl}api/v1/user/blocked-users?page=${currentPage.value}&per_page=20';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final result = BlockedUserResponse.fromJson(decodedData);
        
        if (result.success == true && result.data != null) {
          if (loadMore) {
            blockedUsers.addAll(result.data!);
          } else {
            blockedUsers.assignAll(result.data!);
          }
          hasMore.value = result.pagination?.hasMore ?? false;
        }
      } else {
        Get.snackbar('Error', 'Failed to load blocked users');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      final token = SharedPrefManager().token;
      if (token == null) return;

      final url = '${AppUrls.apiBaseUrl}api/v1/users/$userId/block';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          blockedUsers.removeWhere((user) => user.id == userId);
          Get.snackbar('Success', decodedData['message'] ?? 'User unblocked successfully');
        } else {
          Get.snackbar('Error', decodedData['message'] ?? 'Failed to unblock user');
        }
      } else {
        // Fallback or generic error handling
        final responseData = jsonDecode(response.body);
        Get.snackbar('Error', responseData['message'] ?? 'Failed to unblock user');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
