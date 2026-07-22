import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/exclusive_api_service.dart';
import '../data/model/exclusive_stats_model.dart';
import '../data/model/exclusive_content_item_model.dart';
import 'package:intl/intl.dart';

class CreatorDashboardController extends GetxController {
  final ExclusiveApiService _apiService = Get.find<ExclusiveApiService>();

  // State
  RxBool isLoadingStats = false.obs;
  RxBool isLoadingContent = false.obs;
  
  // Data Models
  Rx<ExclusiveStatsModel?> stats = Rx<ExclusiveStatsModel?>(null);
  RxList<ExclusiveContentItemModel> contentItems = <ExclusiveContentItemModel>[].obs;
  
  // Pagination & Filtering
  RxInt currentPage = 1.obs;
  RxBool hasMoreContent = true.obs;
  RxString selectedSortBy = 'earnings'.obs; // earnings, views, purchases
  RxString selectedOrder = 'desc'.obs; // desc, asc
  RxString selectedContentType = 'all'.obs; // all, post, video, reel

  // Date Filtering
  RxnString dateFrom = RxnString(null);
  RxnString dateTo = RxnString(null);
  RxString selectedDateRangeLabel = 'This Month'.obs;

  @override
  void onInit() {
    super.onInit();
    // Default to this month
    setThisMonth();
    fetchDashboardStats();
    fetchExclusiveContent(isRefresh: true);
  }

  void setThisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    dateFrom.value = formatter.format(firstDay);
    dateTo.value = formatter.format(now);
    selectedDateRangeLabel.value = 'This Month';
  }

  void setAllTime() {
    dateFrom.value = null;
    dateTo.value = null;
    selectedDateRangeLabel.value = 'All Time';
  }

  Future<void> fetchDashboardStats() async {
    isLoadingStats.value = true;
    try {
      final response = await _apiService.getDashboardStats(
        dateFrom: dateFrom.value,
        dateTo: dateTo.value,
        contentType: selectedContentType.value == 'all' ? null : selectedContentType.value,
      );
      
      if (response != null && response['success'] == true && response['data'] != null) {
        stats.value = ExclusiveStatsModel.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint("Error fetching dashboard stats: $e");
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchExclusiveContent({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      contentItems.clear();
      hasMoreContent.value = true;
    }

    if (!hasMoreContent.value) return;
    if (isLoadingContent.value) return;

    isLoadingContent.value = true;
    try {
      final response = await _apiService.getExclusiveContent(
        page: currentPage.value,
        perPage: 15,
        sortBy: selectedSortBy.value,
        order: selectedOrder.value,
        dateFrom: dateFrom.value,
        dateTo: dateTo.value,
        contentType: selectedContentType.value == 'all' ? null : selectedContentType.value,
      );

      if (response != null && response['success'] == true && response['data'] != null) {
        final data = response['data']['data'] as List;
        final newItems = data.map((json) => ExclusiveContentItemModel.fromJson(json)).toList();
        
        contentItems.addAll(newItems);

        final total = response['data']['total'] ?? 0;
        if (contentItems.length >= total || newItems.isEmpty) {
          hasMoreContent.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching exclusive content: $e");
    } finally {
      isLoadingContent.value = false;
    }
  }

  void onSortChange(String newSortBy) {
    if (selectedSortBy.value == newSortBy) {
      selectedOrder.value = selectedOrder.value == 'desc' ? 'asc' : 'desc';
    } else {
      selectedSortBy.value = newSortBy;
      selectedOrder.value = 'desc';
    }
    fetchExclusiveContent(isRefresh: true);
  }

  void applyFilter({String? dateRange, String? contentType}) {
    if (dateRange != null) {
      if (dateRange == 'This Month') {
        setThisMonth();
      } else if (dateRange == 'All Time') {
        setAllTime();
      }
    }
    if (contentType != null) {
      selectedContentType.value = contentType;
    }
    
    fetchDashboardStats();
    fetchExclusiveContent(isRefresh: true);
  }
}
