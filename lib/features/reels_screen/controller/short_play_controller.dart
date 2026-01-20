import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/network/api_services.dart';
import '../../../db/shared_pref_manager.dart';
import '../model/reel_model.dart';

/*class ShortPlayController extends GetxController {
  var selectedPosition = 0.obs;

  String courseCode = "";
  String categoryId = "";

  var reelsList = <ReelModel>[].obs;
 // RxList<ReelModel> reelsList = <ReelModel>[].obs;
  var reelsLoading = false.obs;
  var isAddingFeedBack = false.obs;

  final feedBackController = TextEditingController();

  @override
  void onInit() {
    callAllFunction();
    super.onInit();
  }

  @override
  void dispose() {
    feedBackController.dispose();
    super.dispose();
  }

*//*  Future<void> getShortCourseVideoList() async {
    try {
      if (categoryId.isEmpty || courseCode.isEmpty) {
        showErrorMessage("Short Courses not found");
        return;
      }
      final request = {
        "CategoryId": categoryId,
        "CourseCode": courseCode,
        "MemberId": SharedPrefManager().user?.memberId ?? "",
      };
      // debugPrint("getShortCourseVideoList Request $request");
      reelsLoading.value = true;
      final response = await ApiServices().callPost(
        ApiConstants.getShortCourseVideoList,
        request,
      );
      if (response == null) {
        return;
      }
      if (response['Status'] == true) {
        if (response.containsKey('Response') && response['Response'] is List) {
          final List<dynamic> apiList = response['Response'];

          if (apiList.isNotEmpty) {
            final List<ReelModel> updatedList = apiList.map((e) {
              final modal = shortVideoModalFromMap(jsonEncode(e));
              return ReelModel(
                modal.video,
                modal.title,
                id: modal.pkid,
                courseCategoryId: modal.categoryId,
                isLiked: bool.tryParse(modal.likeStatus) ?? false,
                likeCount: int.tryParse(modal.likeCount) ?? 0,
                feedBack: modal.feedback,
                musicName: modal.courseTitle,
                courseCode: modal.courseCode,
                profileUrl: modal.thumnailImage,
                pdfFile: modal.pdfFile,
                reelDescription: modal.shortDescriptions,
              );
            }).toList();

            reelsList.assignAll(updatedList);
          } else {
            reelsList.clear();
          }
        }
      } else {
        reelsList.clear();
        debugPrint(
          response['Message'] ??
              "getShortCourseVideoList --> Unknown error occurred.",
        );
      }
    } catch (e) {
      debugPrint("getShortCourseVideoList Exception $e");
    } finally {
      reelsLoading.value = false;
    }
  }*//*


  Future<void> fetchReels() async {
    try {
      reelsLoading.value = true;

      final response = await ApiServices().callGet("api/v1/posts/feed/reels");

      print("objectreelresponse : "+response.toString());

      if (response != null && response["data"] != null) {
        reelsList.value = (response["data"] as List)
            .map((e) => ReelModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      reelsLoading.value = false;
    }
  }

  void callAllFunction() {
    getIds();
    fetchReels();
    //getShortCourseVideoList();
  //  saveShortCourseViews();
    // generateDummyVideos();
  }

  void getIds() {
    if (Get.arguments is Map<String, dynamic>) {
      Map<String, dynamic> value = Get.arguments as Map<String, dynamic>;
      if (value.containsKey("CategoryId") && value.containsKey("CourseCode")) {
        courseCode = value["CourseCode"].toString();
        categoryId = value["CategoryId"].toString();
      }
    }
  }

  final RxInt currentIndex = 0.obs;

  final Map<int, VideoPlayerController> cachedControllers = {};

  void onPageChanged(int index) {
    currentIndex.value = index;
    _initControllerAt(index + 1);
    _disposeUnusedControllers(index);
  }

  void _initControllerAt(int index) {
    if (index >= reelsList.length) return;
    if (cachedControllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reelsList[index].media[index].url),
    )..initialize().then((_) {
        update();
      });

    cachedControllers[index] = controller;
  }

  VideoPlayerController? getController(int index) {
    return cachedControllers[index];
  }

  void _disposeUnusedControllers(int currentIndex) {
    cachedControllers.removeWhere((index, controller) {
      if ((index - currentIndex).abs() > 1) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

*//* Future<void> likeReels(
    String videoId,
    bool isTrue, {
    int index = 0,
  }) async {
    try {
      final request = {
        "MemberId": SharedPrefManager().user?.memberId ?? "",
        "IsLike": isTrue,
        "VideoId": videoId
      };
      debugPrint("updateShortVideoLike Request $request");
      final response = await ApiServices().callPostAPI(
        ApiConstants.updateShortVideoLike,
        request,
      );
      if (response == null) {
        return;
      }
      debugPrint("updateShortVideoLike Response $response");
      if (response['Status'] == true) {
        if (response.containsKey('Response') && response['Response'] is List) {
          List<dynamic> apiList = response['Response'];
          if (apiList.isNotEmpty) {
            final apiData = apiList.first as Map;
            if (apiData['Id'] == 1) {
              if (isTrue) {
                reelsList[index].isLiked.value = isTrue;
                if (isTrue) {
                  reelsList[index].likeCount.value += 1;
                }
              }
            }
          }
        }
      } else {
        reelsList[index].isLiked.value = isTrue;
        reelsList[index].likeCount.value -= 1;
        debugPrint(
          response['Message'] ??
              "updateShortVideoLike --> Unknown error occurred.",
        );
      }
    } catch (e) {
      debugPrint("updateShortVideoLike Exception $e");
    }
  }*//*



  Future<void> updateShortVideoLike(int postId, int index) async {
    final stats = reelsList[index].stats;

    stats.isLiked.value = !stats.isLiked.value;
    stats.likeCount.value += stats.isLiked.value ? 1 : -1;

    try {
      await ApiServices().callPost(
        "api/v1/posts/$postId/like",
        data: {},
      );
    } catch (e) {
      // rollback
      stats.isLiked.value = !stats.isLiked.value;
      stats.likeCount.value += stats.isLiked.value ? 1 : -1;
    }
  }




  *//* Future<void> addUpdateTheVideoFeedBack(
    String videoId,
    String feedBack, {
    int index = 0,
  }) async {
    try {
      if (feedBack.isEmpty) {
        showErrorMessage("Please add feedback first");
        return;
      }
      final request = {
        "MemberId": SharedPrefManager().user?.memberId ?? "",
        "FeedBack": feedBack,
        "VideoId": videoId
      };
      isAddingFeedBack.value = true;
      debugPrint("addUpdateTheVideoFeedBack Request $request");
      final response = await ApiServices().callPostAPI(
        ApiConstants.insertUpdateShortVideoFeedback,
        request,
      );
      if (response == null) {
        return;
      }
      debugPrint("addUpdateTheVideoFeedBack Response $response");
      if (response['Status'] == true) {
        if (response.containsKey('Response') && response['Response'] is List) {
          List<dynamic> apiList = response['Response'];
          if (apiList.isNotEmpty) {
            final apiData = apiList.first as Map;
            if (apiData['Id'] == 1) {
              var msg = apiData['Msg'] ?? "Your feedback is recorded";
              Get.back();
              showInformationMessage(msg);
              reelsList[index].feedBack.value = feedBack;
            }
          }
        }
      } else {
        debugPrint(
          response['Message'] ??
              "addUpdateTheVideoFeedBack --> Unknown error occurred.",
        );
      }
    } catch (e) {
      debugPrint("addUpdateTheVideoFeedBack Exception $e");
    } finally {
      isAddingFeedBack.value = false;
    }
  }*//*

  @override
  void onClose() {
    cachedControllers.forEach((_, controller) => controller.dispose());
    super.onClose();
  }

 *//* Future<void> openPdf(String? pdfFile) async {
    try {
      log("openPdf PDF $pdfFile");
      if (pdfFile == null || pdfFile.isEmpty) {
        showErrorMessage("This video does not contain a PDF file");
        return;
      }

      final response = await http.get(Uri.parse(pdfFile));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();

        final fileName =
            'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${directory.path}/$fileName';

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        final result = await OpenFilex.open(filePath);

        if (result.type != ResultType.done) {
          showErrorMessage("Could not open PDF file: ${result.message}");
        }
      } else {
        showErrorMessage(
          "Failed to download PDF file (Error: ${response.statusCode})",
        );
      }
    } catch (e, stackTrace) {
      log("openPdf $e  $stackTrace");
      showErrorMessage("An error occurred while opening the PDF");
    }
  }*//*

  void showErrorMessage(String message) {
    log("Error: $message");
  }


  void updateCommentCount(int postId, bool increase) {
    int index = reelsList.indexWhere((p) => p.id == postId);

    if (index != -1) {
      if (increase) {
        reelsList[index].stats.commentCount.value++;
      } else {
        if (reelsList[index].stats.commentCount.value > 0) {
          reelsList[index].stats.commentCount.value--;
        }
      }

      reelsList.refresh();  // UI update
    }
  }

  // Future<void> saveShortCourseViews() async {
  //   try {
  //     final request = {
  //       "MemberId": SharedPrefManager().user?.memberId ?? "",
  //       "CourseCode": courseCode,
  //     };
  //     debugPrint("saveShortCourseViews Request $request");
  //     final response = await ApiServices().callPostAPI(
  //       ApiConstants.insertShortVideoCourseViews,
  //       request,
  //     );
  //     if (response == null) {
  //       return;
  //     }
  //     debugPrint("saveShortCourseViews Response $response");
  //     if (response['Status'] == true) {
  //       if (response.containsKey('Response') && response['Response'] is List) {
  //         List<dynamic> apiList = response['Response'];
  //         if (apiList.isNotEmpty) {
  //           final apiData = apiList.first as Map;
  //           if (apiData['Id'] == 1) {}
  //         }
  //       }
  //     } else {
  //       debugPrint(
  //         response['Message'] ??
  //             "saveShortCourseViews --> Unknown error occurred.",
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("addUpdateTheVideoFeedBack Exception $e");
  //   }
  // }
  //
  // Future<void> shareReels(BuildContext context, ReelModel model) async {
  //   try {
  //     LoadingDialog.show(context);
  //     final share = SharePlus.instance;
  //     var title = model.videoTitle.toString();
  //     var description =
  //         "${model.reelDescription} \n\n\n *Check out this reel on* \n ${ApiConstants.playStoreUrl}";
  //     await share.share(ShareParams(title: title, text: description));
  //   } catch (e) {
  //     debugPrint("shareReels error: $e");
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Failed to share reel")),
  //       );
  //     }
  //   } finally {
  //     if (context.mounted) LoadingDialog.hide(context);
  //   }
  // }
  //
  // Future<void> setViewsCount(String courseCode, String videoId) async {
  //   try {
  //     final request = {
  //       "MemberId": SharedPrefManager().user?.memberId ?? "",
  //       "CourseCode": courseCode,
  //       "VideoPlayPer": "50%",
  //       "VideoId": int.tryParse(videoId),
  //     };
  //     debugPrint("setViewsCount Request $request");
  //     final response = await ApiServices().callPostAPI(
  //       ApiConstants.insertShortVideoViews,
  //       request,
  //     );
  //     if (response == null) {
  //       return;
  //     }
  //     debugPrint("setViewsCount Response $response");
  //     if (response['Status'] == true) {
  //       if (response.containsKey('Response') && response['Response'] is List) {
  //         List<dynamic> apiList = response['Response'];
  //         if (apiList.isNotEmpty) {
  //           final apiData = apiList.first as Map;
  //           if (apiData['Id'] == 1) {}
  //         }
  //       }
  //     } else {
  //       debugPrint(
  //         response['Message'] ?? "setViewsCount --> Unknown error occurred.",
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("setViewsCount Exception $e");
  //   }
  // }
}*/




class ShortPlayController extends GetxController {
  var selectedPosition = 0.obs;

  String courseCode = "";
  String categoryId = "";

  var reelsList = <ReelModel>[].obs; // the reactive list
  var reelsLoading = false.obs;
  var isAddingFeedBack = false.obs;

  final feedBackController = TextEditingController();

  // We create maps for per-reel reactive stats
  final Map<int, RxInt> likeCounts = {};
  final Map<int, RxInt> commentCounts = {};
  final Map<int, RxBool> isLikedMap = {};

  @override
  void onInit() {
    callAllFunction();
    super.onInit();
  }

  @override
  void dispose() {
    feedBackController.dispose();
    super.dispose();
  }

  Future<void> fetchReels() async {
    try {
      reelsLoading.value = true;

      final response = await ApiServices().callGet("api/v1/posts/feed/reels");

      print("objectreelresponse : " + response.toString());

      if (response != null && response["data"] != null) {
        final fetchedReels = (response["data"] as List)
            .map((e) => ReelModel.fromJson(e))
            .toList();

        // Initialize reactive stats
        for (var i = 0; i < fetchedReels.length; i++) {
          likeCounts[i] = (fetchedReels[i].stats.likeCount).obs;
          commentCounts[i] = (fetchedReels[i].stats.commentCount).obs;
          isLikedMap[i] = (fetchedReels[i].stats.isLiked).obs;
        }

        reelsList.value = fetchedReels;
      }
    } catch (e) {
      print("Error fetching reels: $e");
    } finally {
      reelsLoading.value = false;
    }
  }

  void callAllFunction() {
    getIds();
    fetchReels();
  }

  void getIds() {
    if (Get.arguments is Map<String, dynamic>) {
      Map<String, dynamic> value = Get.arguments as Map<String, dynamic>;
      if (value.containsKey("CategoryId") && value.containsKey("CourseCode")) {
        courseCode = value["CourseCode"].toString();
        categoryId = value["CategoryId"].toString();
      }
    }
  }

  final RxInt currentIndex = 0.obs;
  final Map<int, VideoPlayerController> cachedControllers = {};

  void onPageChanged(int index) {
    currentIndex.value = index;
    _initControllerAt(index + 1);
    _disposeUnusedControllers(index);
  }

  void _initControllerAt(int index) {
    if (index >= reelsList.length) return;
    if (cachedControllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reelsList[index].media[0].url),
    )..initialize().then((_) {
      update();
    });

    cachedControllers[index] = controller;
  }

  VideoPlayerController? getController(int index) {
    return cachedControllers[index];
  }

  void _disposeUnusedControllers(int currentIndex) {
    cachedControllers.removeWhere((index, controller) {
      if ((index - currentIndex).abs() > 1) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  Future<void> updateShortVideoLike(int postId, int index) async {
    final statsLike = isLikedMap[index]!;
    final statsCount = likeCounts[index]!;

    statsLike.value = !statsLike.value;
    statsCount.value += statsLike.value ? 1 : -1;

    try {
      await ApiServices().callPost(
        "api/v1/posts/$postId/like",
        data: {},
      );
    } catch (e) {
      // rollback if API fails
      statsLike.value = !statsLike.value;
      statsCount.value += statsLike.value ? 1 : -1;
    }
  }

  void updateCommentCount(int postId, bool increase) {
    int index = reelsList.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final count = commentCounts[index]!;
      if (increase) {
        count.value++;
      } else {
        if (count.value > 0) count.value--;
      }
    }
  }

  @override
  void onClose() {
    cachedControllers.forEach((_, controller) => controller.dispose());
    super.onClose();
  }

  void showErrorMessage(String message) {
    log("Error: $message");
  }
}
