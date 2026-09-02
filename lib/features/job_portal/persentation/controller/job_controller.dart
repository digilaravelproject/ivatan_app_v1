import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../data/model/job_model.dart';
import '../../repository/job_repository.dart';
import 'job_portal_controller.dart';


class JobController extends GetxController with GetSingleTickerProviderStateMixin {
  final JobRepository repository;

  JobController(this.repository);

  final TextEditingController searchController = TextEditingController();
  var searchText = ''.obs;
  final RxInt selectedCompanyIndex = 0.obs;
  final RxString selectedFilter = 'All'.obs;

  var isMoreLoading = false.obs;   // scroll bottom me loader
  int currentPage = 1;
  bool hasMore = true;
  final ScrollController scrollController = ScrollController();

  // Create Job Controllers
  final minSalaryController = TextEditingController();
  final companyNameController = TextEditingController();
  final titleFormController = TextEditingController();
  final companyWebsiteController = TextEditingController(text: "https://");
  final descriptionFormController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final responsibilitiesController = TextEditingController();
  final requirementsController = TextEditingController();
  final locationController = TextEditingController();
  final countryController = TextEditingController();

  final RxString selectedEmploymentType = 'full_time'.obs;
  final RxString selectedCurrency = 'INR'.obs;
  final RxString selectedStatus = 'published'.obs;
  final RxBool isRemote = true.obs;
  final RxBool isUrgent = false.obs;

  // Search variables
  final RxString searchQ = ''.obs;

  // Image upload
  final companyLogoFile = Rx<File?>(null);
  final editingJobLogoUrl = RxnString(); // existing logo URL when editing

  // Form validation errors
  final companyNameError = ''.obs;
  final titleError = ''.obs;
  final websiteError = ''.obs;
  final descriptionError = ''.obs;
  final responsibilitiesError = ''.obs;
  final requirementsError = ''.obs;
  final locationError = ''.obs;
  final countryError = ''.obs;
  final minSalaryError = ''.obs;
  final maxSalaryError = ''.obs;

  final isFormValid = false.obs;

  var isCreating = false.obs;
  var isEditing = false.obs;
  var editingJobId = RxnInt();

  var isLoading = false.obs;
  var jobList = <JobModel>[].obs;
  var jobDaysAgo = <int>[].obs;

  late final TabController tabController;


  @override
  void onInit() {
    super.onInit();
    fetchJobs();
    tabController = TabController(length: 2, vsync: this);
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200 &&
          !isMoreLoading.value &&
          hasMore) {
        loadMoreJobs();
      }
    });

    // Debounce search
    debounce(searchQ, (_) => fetchJobs(), time: const Duration(milliseconds: 500));
  }

  // Removed updateFilters and clearFilters

  void validateForm() {
    // Clear all errors first
    companyNameError.value = '';
    titleError.value = '';
    websiteError.value = '';
    descriptionError.value = '';
    responsibilitiesError.value = '';
    requirementsError.value = '';
    locationError.value = '';
    countryError.value = '';
    minSalaryError.value = '';
    maxSalaryError.value = '';

    bool isValid = true;

    // Validate company name
    if (companyNameController.text.trim().isEmpty) {
      companyNameError.value = 'Company name is required';
      isValid = false;
    }

    // Validate title
    if (titleFormController.text.trim().isEmpty) {
      titleError.value = 'Job title is required';
      isValid = false;
    }

    // Validate website
    final websiteText = companyWebsiteController.text.trim();
    if (websiteText.isEmpty || websiteText == "https://") {
      websiteError.value = 'Company website is required';
      isValid = false;
    } else {
      final urlPattern = r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?(\/.*)?$';
      final websiteRegExp = RegExp(urlPattern, caseSensitive: false);
      if (!websiteRegExp.hasMatch(websiteText)) {
        websiteError.value = 'Please enter a valid website URL';
        isValid = false;
      }
    }

    // Validate description
    if (descriptionFormController.text.trim().isEmpty) {
      descriptionError.value = 'Job description is required';
      isValid = false;
    }

    // Validate responsibilities
    if (responsibilitiesController.text.trim().isEmpty) {
      responsibilitiesError.value = 'Responsibilities are required';
      isValid = false;
    }

    // Validate requirements
    if (requirementsController.text.trim().isEmpty) {
      requirementsError.value = 'Requirements are required';
      isValid = false;
    }

    // Validate location
    if (locationController.text.trim().isEmpty) {
      locationError.value = 'Location is required';
      isValid = false;
    }

    // Validate country
    if (countryController.text.trim().isEmpty) {
      countryError.value = 'Country is required';
      isValid = false;
    }

    // Validate min salary
    if (minSalaryController.text.trim().isEmpty) {
      minSalaryError.value = 'Minimum salary is required';
      isValid = false;
    } else if (double.tryParse(minSalaryController.text) == null) {
      minSalaryError.value = 'Enter a valid number';
      isValid = false;
    }

    // Validate max salary
    if (maxSalaryController.text.trim().isEmpty) {
      maxSalaryError.value = 'Maximum salary is required';
      isValid = false;
    } else if (double.tryParse(maxSalaryController.text) == null) {
      maxSalaryError.value = 'Enter a valid number';
      isValid = false;
    } else if (double.tryParse(minSalaryController.text) != null &&
        double.tryParse(maxSalaryController.text)! <
            double.tryParse(minSalaryController.text)!) {
      maxSalaryError.value = 'Max salary must be greater than min';
      isValid = false;
    }

    isFormValid.value = isValid;
  }

  Future<void> fetchJobs() async {
    try {
      isLoading.value = true;
      currentPage = 1;
      hasMore = true;

      final jobs = await repository.getJobs(
        q: searchQ.value,
        page: currentPage,
      );
      jobList.assignAll(jobs);
      calculateDaysAgo();
      print("joblist in controller : "+jobList.length.toString());
    } catch (e, stacktrace) {
      print("fetchJobs error: $e");
      print(stacktrace);
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> loadMoreJobs() async {
    if (!hasMore) return;

    isMoreLoading.value = true;
    currentPage++;

    try {
      final jobs = await repository.getJobs(
        q: searchQ.value,
        page: currentPage,
      );
      if (jobs.isEmpty) {
        hasMore = false;
      } else {
        jobList.addAll(jobs);
        calculateDaysAgo();
      }
    } catch (e, stacktrace) {
      print("loadMoreJobs error: $e");
      print(stacktrace);
      hasMore = false;
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> createJob() async {
    try {
      // Validate form before creating
      validateForm();
      if (!isFormValid.value) {
        Get.snackbar(
          'Validation Error',
          'Please fill all required fields correctly',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: AppColors.white,
        );
        return;
      }

      isCreating.value = true;

      final request = CreateJobRequestModel(
        title: titleFormController.text,
        companyName: companyNameController.text,
        companyWebsite: companyWebsiteController.text.isNotEmpty ? companyWebsiteController.text : null,
        description: descriptionFormController.text,
        employmentType: selectedEmploymentType.value,
        salaryMin: double.tryParse(minSalaryController.text) ?? 50000.0,
        salaryMax: double.tryParse(maxSalaryController.text) ?? 80000.0,
        currency: selectedCurrency.value,
        isRemote: isRemote.value,
        isUrgent: isUrgent.value,
        status: selectedStatus.value,
        responsibilities: isEditing.value || responsibilitiesController.text.isNotEmpty ? responsibilitiesController.text : null,
        requirements: isEditing.value || requirementsController.text.isNotEmpty ? requirementsController.text : null,
        location: isEditing.value || locationController.text.isNotEmpty ? locationController.text : null,
        country: isEditing.value || countryController.text.isNotEmpty ? countryController.text : null,
      );

      final message = isEditing.value
          ? await repository.updateJob(editingJobId.value!, request, logoFile: companyLogoFile.value)
          : await repository.createJob(request, logoFile: companyLogoFile.value);

      if (message != null) {
        Get.back();
        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: AppColors.white,
        );
        fetchJobs();
        clearForm();
      } else {
        Get.snackbar(
          'Error',
          isEditing.value ? 'Failed to update job.' : 'Failed to create job.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }

  void setEditingJob(JobModel job) {
    isEditing.value = true;
    editingJobId.value = job.id;
    
    titleFormController.text = job.title;
    companyNameController.text = job.companyName;
    companyWebsiteController.text = job.companyWebsite ?? '';
    descriptionFormController.text = job.description;
    minSalaryController.text = job.salaryMin.toString();
    maxSalaryController.text = job.salaryMax.toString();
    selectedEmploymentType.value = job.employmentType;
    selectedCurrency.value = job.currency;
    selectedStatus.value = job.status;
    isRemote.value = job.isRemote;
    isUrgent.value = job.isUrgentActive;
    editingJobLogoUrl.value = job.companyLogo; // store existing logo URL
    responsibilitiesController.text = job.responsibilities ?? '';
    requirementsController.text = job.requirements ?? '';
    locationController.text = job.location;
    countryController.text = job.country;
    
    // Enable update button by default when editing
    isFormValid.value = true;
  }

  void clearForm() {
    isEditing.value = false;
    editingJobId.value = null;
    
    titleFormController.clear();
    companyNameController.clear();
    companyWebsiteController.clear();
    descriptionFormController.clear();
    minSalaryController.clear();
    maxSalaryController.clear();
    responsibilitiesController.clear();
    requirementsController.clear();
    locationController.clear();
    countryController.clear();
    
    companyLogoFile.value = null;
    editingJobLogoUrl.value = null;
    
    // Clear all errors
    companyNameError.value = '';
    titleError.value = '';
    websiteError.value = '';
    descriptionError.value = '';
    responsibilitiesError.value = '';
    requirementsError.value = '';
    locationError.value = '';
    countryError.value = '';
    minSalaryError.value = '';
    maxSalaryError.value = '';
    
    selectedEmploymentType.value = 'full_time';
    selectedCurrency.value = 'INR';
    selectedStatus.value = 'published';
    isRemote.value = true;
    isUrgent.value = false;
    isFormValid.value = false;
  }

  void calculateDaysAgo() {
    jobDaysAgo.clear(); // purani values remove karo

    for (var job in jobList) {
      try {
        final createdDate = DateTime.parse(job.createdAt);
        final now = DateTime.now();
        final difference = now.difference(createdDate).inDays;

        jobDaysAgo.add(difference);
        print("jobDaysAgo : "+jobDaysAgo.string);// variable me store
      } catch (e) {
        jobDaysAgo.add(0); // agar date parsing fail ho jaye
      }
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    companyNameController.dispose();
    companyWebsiteController.dispose();
    titleFormController.dispose();
    descriptionFormController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    responsibilitiesController.dispose();
    requirementsController.dispose();
    locationController.dispose();
    countryController.dispose();
    super.onClose();
  }


  final List<Company> companies = [
    Company('Google', 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png'),
    Company('Apple', 'https://cdn-icons-png.flaticon.com/512/731/731985.png'),
    Company('Microsoft', 'https://cdn-icons-png.flaticon.com/512/732/732221.png'),
    Company('Amazon', 'https://cdn-icons-png.flaticon.com/512/731/731966.png'),
    Company('Facebook', 'https://cdn-icons-png.flaticon.com/512/733/733547.png'),
  ];


  final List<Job> recentJobs = [
    Job(
      companyName: 'Microsoft',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/732/732221.png',
      position: 'Cloud Architect',
      location: 'Lucknow',
      type: 'Remote',
      description: 'Design and implement cloud solutions using Azure. Must have 5+ years experience in cloud architecture.',
      daysLeft: 7,
      salary: 200,
    ),
    Job(
      companyName: 'Amazon',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/731/731966.png',
      position: 'Mumbai',
      location: 'Seattle, WA',
      type: 'Full Time',
      description: 'Analyze large datasets and build machine learning models to improve customer experience.',
      daysLeft: 5,
      salary: 170,
    ),
    Job(
      companyName: 'Netflix',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/732/732228.png',
      position: 'Content Strategist',
      location: 'Los Gatos, CA',
      type: 'Contract',
      description: 'Develop content strategies for original programming and global content distribution.',
      daysLeft: 10,
      salary: 150,
    ),
  ];

  void selectCompany(int index) {
    selectedCompanyIndex.value = index;
    // Here you would typically filter jobs based on selected company
  }


}
