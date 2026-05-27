import 'package:get/get.dart';
import '../../../../core/network/api_services.dart';
import '../model/history_model.dart';

class HistoryController extends GetxController {
  final ApiServices _apiService = Get.put(ApiServices());

  // --- State for Video Views (Top slider) ---
  var videoViews = <VideoViewHistoryItem>[].obs;
  var isLoadingVideoViews = false.obs;
  String? nextCursorVideoViews;
  bool hasMoreVideoViews = true;

  // --- State for Likes ---
  var likes = <LikeHistoryItem>[].obs;
  var isLoadingLikes = false.obs;
  String? nextCursorLikes;
  bool hasMoreLikes = true;

  // --- State for Comments ---
  var comments = <CommentHistoryItem>[].obs;
  var isLoadingComments = false.obs;
  String? nextCursorComments;
  bool hasMoreComments = true;

  // --- State for Purchases (Products) ---
  var purchases = <PurchaseHistoryItem>[].obs;
  var isLoadingPurchases = false.obs;
  String? nextCursorPurchases;
  bool hasMorePurchases = true;

  // --- State for Services ---
  var services = <PurchaseHistoryItem>[].obs;
  var isLoadingServices = false.obs;
  String? nextCursorServices;
  bool hasMoreServices = true;

  @override
  void onInit() {
    super.onInit();
    // Fetch initial data
    fetchVideoViews();
    fetchLikes();
    fetchComments();
    fetchPurchases();
    fetchServices();
  }

  Future<void> fetchVideoViews({bool loadMore = false}) async {
    if (isLoadingVideoViews.value || (!hasMoreVideoViews && loadMore)) return;
    
    if (loadMore) {
      isLoadingVideoViews.value = true;
    } else {
      videoViews.clear();
      nextCursorVideoViews = null;
      hasMoreVideoViews = true;
      isLoadingVideoViews.value = true;
    }

    String url = "api/v1/history/video-views?per_page=20";
    if (nextCursorVideoViews != null) {
      url += "&cursor=$nextCursorVideoViews";
    }

    try {
      final response = await _apiService.callGet(url);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        final data = rawData is Map ? (rawData['data'] as List? ?? []) : (rawData as List? ?? []);
        final items = data.map((e) => VideoViewHistoryItem.fromJson(e)).toList();
        
        if (loadMore) {
          videoViews.addAll(items);
        } else {
          videoViews.value = items;
        }

        final meta = response['meta'];
        if (meta != null) {
          nextCursorVideoViews = meta['next_cursor'];
          hasMoreVideoViews = meta['has_more'] ?? false;
        } else {
          hasMoreVideoViews = false;
        }
      }
    } catch (e) {
      print("Error fetching video views history: $e");
    } finally {
      isLoadingVideoViews.value = false;
    }
  }

  Future<void> fetchLikes({bool loadMore = false}) async {
    if (isLoadingLikes.value || (!hasMoreLikes && loadMore)) return;
    
    isLoadingLikes.value = true;
    if (!loadMore) {
      likes.clear();
      nextCursorLikes = null;
      hasMoreLikes = true;
    }

    String url = "api/v1/history/likes?per_page=20";
    if (nextCursorLikes != null) {
      url += "&cursor=$nextCursorLikes";
    }

    try {
      final response = await _apiService.callGet(url);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        final data = rawData is Map ? (rawData['data'] as List? ?? []) : (rawData as List? ?? []);
        final items = data.map((e) => LikeHistoryItem.fromJson(e)).toList();
        
        if (loadMore) {
          likes.addAll(items);
        } else {
          likes.value = items;
        }

        final meta = response['meta'];
        if (meta != null) {
          nextCursorLikes = meta['next_cursor'];
          hasMoreLikes = meta['has_more'] ?? false;
        } else {
          hasMoreLikes = false;
        }
      }
    } catch (e) {
      print("Error fetching likes history: $e");
    } finally {
      isLoadingLikes.value = false;
    }
  }

  Future<void> fetchComments({bool loadMore = false}) async {
    if (isLoadingComments.value || (!hasMoreComments && loadMore)) return;
    
    isLoadingComments.value = true;
    if (!loadMore) {
      comments.clear();
      nextCursorComments = null;
      hasMoreComments = true;
    }

    String url = "api/v1/history/comments?per_page=20";
    if (nextCursorComments != null) {
      url += "&cursor=$nextCursorComments";
    }

    try {
      final response = await _apiService.callGet(url);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        final data = rawData is Map ? (rawData['data'] as List? ?? []) : (rawData as List? ?? []);
        final items = data.map((e) => CommentHistoryItem.fromJson(e)).toList();
        
        if (loadMore) {
          comments.addAll(items);
        } else {
          comments.value = items;
        }

        final meta = response['meta'];
        if (meta != null) {
          nextCursorComments = meta['next_cursor'];
          hasMoreComments = meta['has_more'] ?? false;
        } else {
          hasMoreComments = false;
        }
      }
    } catch (e) {
      print("Error fetching comments history: $e");
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> fetchPurchases({bool loadMore = false}) async {
    if (isLoadingPurchases.value || (!hasMorePurchases && loadMore)) return;
    
    isLoadingPurchases.value = true;
    if (!loadMore) {
      purchases.clear();
      nextCursorPurchases = null;
      hasMorePurchases = true;
    }

    String url = "api/v1/history/purchases?per_page=20";
    if (nextCursorPurchases != null) {
      url += "&cursor=$nextCursorPurchases";
    }

    try {
      final response = await _apiService.callGet(url);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        final data = rawData is Map ? (rawData['data'] as List? ?? []) : (rawData as List? ?? []);
        final items = data.map((e) => PurchaseHistoryItem.fromJson(e)).toList();
        
        if (loadMore) {
          purchases.addAll(items);
        } else {
          purchases.value = items;
        }

        final meta = response['meta'];
        if (meta != null) {
          nextCursorPurchases = meta['next_cursor'];
          hasMorePurchases = meta['has_more'] ?? false;
        } else {
          hasMorePurchases = false;
        }
      }
    } catch (e) {
      print("Error fetching purchases history: $e");
    } finally {
      isLoadingPurchases.value = false;
    }
  }

  Future<void> fetchServices({bool loadMore = false}) async {
    if (isLoadingServices.value || (!hasMoreServices && loadMore)) return;
    
    isLoadingServices.value = true;
    if (!loadMore) {
      services.clear();
      nextCursorServices = null;
      hasMoreServices = true;
    }

    String url = "api/v1/history/services?per_page=20";
    if (nextCursorServices != null) {
      url += "&cursor=$nextCursorServices";
    }

    try {
      final response = await _apiService.callGet(url);
      if (response != null && response['success'] == true) {
        final rawData = response['data'];
        final data = rawData is Map ? (rawData['data'] as List? ?? []) : (rawData as List? ?? []);
        final items = data.map((e) => PurchaseHistoryItem.fromJson(e)).toList();
        
        if (loadMore) {
          services.addAll(items);
        } else {
          services.value = items;
        }

        final meta = response['meta'];
        if (meta != null) {
          nextCursorServices = meta['next_cursor'];
          hasMoreServices = meta['has_more'] ?? false;
        } else {
          hasMoreServices = false;
        }
      }
    } catch (e) {
      print("Error fetching services history: $e");
    } finally {
      isLoadingServices.value = false;
    }
  }
}
