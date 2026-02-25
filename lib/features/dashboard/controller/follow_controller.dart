import 'dart:convert';

import 'package:get/get.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import '../../../core/network/api_services.dart';
import 'package:http/http.dart' as http;




class FollowController extends GetxController {
  final ApiServices api = ApiServices();

  RxMap<int, RxBool> followStatus = <int, RxBool>{}.obs;

  RxBool isUserFollowing(int userId, {bool? initialValue}) {
    if (!followStatus.containsKey(userId)) {
      // Return a dummy RxBool if not found, but DON'T add to map during build phase
      return (initialValue ?? false).obs;
    }
    return followStatus[userId]!;
  }
  void setInitialFollowStatus(int userId, bool isFollowing) {
    if (followStatus.containsKey(userId)) {
      followStatus[userId]!.value = isFollowing;
    } else {
      followStatus[userId] = isFollowing.obs;
    }
  }

  // FOLLOW
  Future<void> followUser(int userId) async {
    final response = await api.callPost("api/v1/follow/$userId", data: {});
    print("followuser : $response");

    if (response == null) return;

    final msg = response["message"] ?? "";

    if (msg == "Followed successfully.") {
      isUserFollowing(userId).value = true;
    }
    else if (msg == "Already following.") {
      isUserFollowing(userId).value = true; // <-- IMPORTANT
    }
  }

  Future<void> unfollowUser(int userId) async {
    final response = await api.callDelete("api/v1/follow/$userId");
    print("unfollowuser : $response");

    if (response == null) return;

    final msg = response["message"] ?? "";

    if (msg == "Unfollowed successfully.") {
      isUserFollowing(userId).value = false;
    }
  }


  // TOGGLE
  Future<void> toggleFollow(int userId) async {
    if (isUserFollowing(userId).value) {
      await unfollowUser(userId);
    } else {
      await followUser(userId);
    }
  }
}

