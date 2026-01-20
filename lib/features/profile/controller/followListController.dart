import 'package:get/get.dart';
import '../../../core/network/api_services.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../model/followers_model.dart';


class FollowListController extends GetxController {
  final int userId;

  FollowListController({required this.userId});
  final FollowController followController = Get.put(FollowController());


  final ApiServices api = Get.put(ApiServices());

  /// FOLLOWERS STATE
  RxBool followersLoading = false.obs;
  RxBool followersMore = true.obs;
  RxList<UserFollower> followerList = <UserFollower>[].obs;
  RxList<UserFollower> filteredFollowerList = <UserFollower>[].obs; // Filtered List
  int followersPage = 1;
  int followersLastPage = 1;

  /// FOLLOWING STATE
  RxBool followingsLoading = false.obs;
  RxBool followingsMore = true.obs;
  RxList<UserFollower> followingList = <UserFollower>[].obs;
  RxList<UserFollower> filteredFollowingList = <UserFollower>[].obs; // Filtered List
  int followingsPage = 1;
  int followingsLastPage = 1;

  @override
  void onInit() {
    fetchFollowers();
    fetchFollowings();
    super.onInit();
  }

  Future<void> fetchFollowers({bool loadMore = false}) async {
    if (followersLoading.value) return;

    if (!loadMore) {
      followersPage = 1;
      followerList.clear();
      followersMore.value = true;
    } else {
      if (!followersMore.value) return;
      followersPage++;
    }

    try {
      followersLoading.value = true;

      final response =
      await api.callGet("api/v1/user/$userId/followers?page=$followersPage");

      if (response == null || response["data"] == null) {
        followersMore.value = false;
        return;
      }

      followersLastPage = response["meta"]?["last_page"] ?? 1;

      List data = response["data"] as List;
      followerList.addAll(
          data.map((e) => UserFollower.fromJson(e)).toList());

      filteredFollowerList.addAll(
          data.map((e) => UserFollower.fromJson(e)).toList());

      if (followersPage >= followersLastPage) {
        followersMore.value = false;
      }
    } catch (e) {
      print("Followers Error: $e");
      followersMore.value = false;
    } finally {
      followersLoading.value = false;
    }
  }

  void filterFollowerSearch(String query) {
    if (query.isEmpty) {
      filteredFollowerList.assignAll(followerList);
    } else {
      filteredFollowerList.assignAll(
        followerList.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }


  Future<void> toggleFollowUser(int selectedUserId) async {
    try {
      // Backend call
      await followController.toggleFollow(selectedUserId);

      int index1 = followerList.indexWhere((e) => e.id == selectedUserId);
      if (index1 != -1) {
        followerList[index1].isFollowedByAuthUser =
        !followerList[index1].isFollowedByAuthUser;
        followerList.refresh();
        fetchFollowings();
      }

      int index2 = filteredFollowerList.indexWhere((e) => e.id == selectedUserId);
      if (index2 != -1) {
        filteredFollowerList[index2].isFollowedByAuthUser =
        !filteredFollowerList[index2].isFollowedByAuthUser;
        filteredFollowerList.refresh();
      }

      int index3 = followingList.indexWhere((e) => e.id == selectedUserId);
      if (index3 != -1) {
        followingList[index3].isFollowedByAuthUser =
        !followingList[index3].isFollowedByAuthUser;
        fetchFollowers();
        followingList.refresh();
      }

      int index4 = filteredFollowingList.indexWhere((e) => e.id == selectedUserId);
      if (index4 != -1) {
        filteredFollowingList[index4].isFollowedByAuthUser =
        !filteredFollowingList[index4].isFollowedByAuthUser;
        filteredFollowingList.refresh();
      }

    } catch (e) {
      print("Follow Error: $e");
    }
  }



  Future<void> fetchFollowings({bool loadMore = false}) async {
    if (followingsLoading.value) return;

    if (!loadMore) {
      followingsPage = 1;
      followingList.clear();
      followingsMore.value = true;
    } else {
      if (!followingsMore.value) return;
      followingsPage++;
    }

    try {
      followingsLoading.value = true;

      final response =
      await api.callGet("api/v1/user/$userId/following?page=$followingsPage");

      if (response == null || response["data"] == null) {
        followingsMore.value = false;
        return;
      }

      followingsLastPage = response["meta"]?["last_page"] ?? 1;

      List data = response["data"] as List;
      followingList.addAll(
          data.map((e) => UserFollower.fromJson(e)).toList());

      filteredFollowingList.addAll(
          data.map((e) => UserFollower.fromJson(e)).toList());

      if (followingsPage >= followingsLastPage) {
        followingsMore.value = false;
      }
    } catch (e) {
      print("Following Error: $e");
      followingsMore.value = false;
    } finally {
      followingsLoading.value = false;
    }
  }


  void filterFollowing(String query) {
    if (query.isEmpty) {
      filteredFollowingList.assignAll(followingList);
    } else {
      filteredFollowingList.assignAll(
        followingList.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }

}
