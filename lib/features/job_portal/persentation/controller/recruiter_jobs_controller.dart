import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/job_model.dart';
import '../../repository/job_repository.dart';

class RecruiterJobsController extends GetxController {
  final JobRepository repository;

  RecruiterJobsController({required this.repository});

  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJobs();
    scrollController.addListener(_scrollListener);
    
    // Set up debouncing for search
    debounce(searchText, (String value) {
      fetchJobs(search: value);
    }, time: const Duration(milliseconds: 600));
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (currentPage.value < lastPage.value && !isMoreLoading.value) {
        fetchMoreJobs();
      }
    }
  }

  Future<void> fetchJobs({String? search}) async {
    isLoading.value = true;
    currentPage.value = 1;
    jobs.clear();

    try {
      final result = await repository.getRecruiterJobs(
        page: currentPage.value,
        search: search ?? searchText.value,
      );
      
      jobs.assignAll(result['jobs'] as List<JobModel>);
      currentPage.value = result['current_page'];
      lastPage.value = result['last_page'];
    } catch (e) {
      print('Error fetching recruiter jobs: $e');
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> fetchMoreJobs() async {
    isMoreLoading.value = true;
    
    try {
      final result = await repository.getRecruiterJobs(
        page: currentPage.value + 1,
        search: searchText.value,
      );
      
      jobs.addAll(result['jobs'] as List<JobModel>);
      currentPage.value = result['current_page'];
      lastPage.value = result['last_page'];
    } catch (e) {
      print('Error fetching more recruiter jobs: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  void searchJobs(String query) {
    searchText.value = query;
    fetchJobs(search: query);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }




}
