

import 'package:get/get.dart';

import '../../../core/network/api_services.dart';

import '../../reels_screen/controller/short_play_controller.dart';
import '../model/comment_model.dart';
import 'homeController.dart';

class CommentController extends GetxController {
  final ApiServices api = ApiServices();

  final HomeController homeController = Get.find<HomeController>();
  final ShortPlayController reelsController = Get.find<ShortPlayController>();

  // UI reactive lists
  RxList<CommentModel> commentsList = <CommentModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> fetchComments(int postId) async {
    try {
      isLoading.value = true;

      final response =
      await api.callGet("api/v1/comments/post/$postId");

      print("Fetch Comments: $response");

      if (response != null && response["data"] != null) {
        final commentResponse = CommentResponse.fromJson(response);

        commentsList.value = commentResponse.data; // SET LIST
      }
    } catch (e) {
      print("Comment Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createComment({required int postId, required String body}) async {
    try {
      final response = await api.callPost(
        "api/v1/comments/UserPost/$postId",
        data: {
          "body": body,
        },
      );

      print("Create Comment Response: $response");

      if (response != null && response["data"] != null) {
        // Optionally add the newly created comment to the list
        commentsList.insert(0, CommentModel.fromJson(response["data"]));
        homeController.updateCommentCount(postId, true);
        reelsController.updateCommentCount(postId, true);

      }
    } catch (e) {
      print("Create Comment Error: $e");
    }
  }

  Future<void> createReplyComment({required int postId,required int commentId, required String body}) async {
    try {
      final response = await api.callPost(
        "api/v1/comments/UserPost/$postId/$commentId",
        data: {
          "body": body,
        },
      );

      print("Create reply Comment Response: $response");

      if (response != null && response["data"] != null) {
        // Optionally add the newly created comment to the list
       // commentsList.insert(0, CommentModel.fromJson(response["data"]));
        final newReply = CommentModel.fromJson(response["data"]);

        // Find parent comment inside commentsList
        final parentIndex = commentsList.indexWhere((c) => c.id == commentId);

        if (parentIndex != -1) {
          commentsList[parentIndex].replies.add(newReply);

          // To refresh UI
          commentsList.refresh();
        }

      }
    } catch (e) {
      print("Create reply Comment Error: $e");
    }
  }

  Future<void> likeComment(int commentId, int index) async {
    try {
      final response = await api.callPost(
        "api/v1/comments/like/$commentId",
        data: {},
      );

      print("likeResponse : $response");

      if (response != null &&
          response["data"] != null &&
          response["data"]["liked"] != null &&
          response["data"]["likes_count"] != null)
      {
        bool newLikeStatus = response["data"]["liked"];
        int newCount = response["data"]["likes_count"];

        // 🟢 Update ONLY clicked post
        commentsList[index].hasLiked = newLikeStatus;
        commentsList[index].likesCount = newCount;

        // 🔄 Refresh only that post
        commentsList.refresh();
      }

    } catch (e) {
      print("Like Error: $e");
    }
  }

/*
  Future<void> deleteComments(int commentId) async {
    final response = await api.callDelete("api/v1/comments/$commentId");
    print("allComments : $response");

    if (response == null) return;

    final msg = response["message"] ?? "";

    //  print("allComments  : "+)

    if (msg == "Unfollowed successfully.") {
      // isUserFollowing(userId).value = false;
    }
  }
*/

  Future<bool> deleteComments(int postId,int commentId) async {
    try {
      final response = await api.callDelete("api/v1/comments/$commentId");

      print("Delete Comment Response: $response");

      if (response == null) return false;

      final msg = response["message"] ?? "";

      final status = response["success"] == true;

      if (status) {

     // if (msg.toLowerCase().contains("Comment deleted")) {

       // commentsList.removeWhere((c) => c.id == commentId);

        // 🔥 UPDATE HOME COMMENT COUNT
        homeController.updateCommentCount(postId, false);
        reelsController.updateCommentCount(postId, false);

        Get.snackbar(
          "Deleted",
          "Comment removed successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
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


}




