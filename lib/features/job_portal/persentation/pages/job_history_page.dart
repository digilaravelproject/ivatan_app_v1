import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import '../controller/job_controller.dart';
import '../../data/model/user_application_model.dart';
import '../../repository/job_repository.dart';

class JobHistoryController extends GetxController {
  final JobRepository repository;

  JobHistoryController(this.repository);

  var searchText = ''.obs;
  var selectedFilter = 'all'.obs;
  final TextEditingController searchController = TextEditingController();

  var applications = <UserApplication>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var totalApplications = 0.obs;
  
  late ScrollController scrollController;

  final filters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'applied', 'label': 'Applied'},
    {'value': 'viewed', 'label': 'Viewed'},
    {'value': 'accepted', 'label': 'Accepted'},
    {'value': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    fetchApplications();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (currentPage.value < lastPage.value && !isLoadingMore.value) {
        loadMoreApplications();
      }
    }
  }

  Future<void> fetchApplications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        applications.clear();
      }
      isLoading.value = true;
      final status = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final result = await repository.getUserApplications(status: status);
      applications.assignAll(result);
    } catch (e) {
      print('Error fetching applications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreApplications() async {
    try {
      isLoadingMore.value = true;
      currentPage.value++;
      final status = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final result = await repository.getUserApplications(status: status);
      applications.addAll(result);
    } catch (e) {
      print('Error loading more applications: $e');
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  List<UserApplication> get filteredApplications {
    return applications
        .where((app) =>
            (selectedFilter.value == 'all' ||
                app.status == selectedFilter.value) &&
            (app.job.title
                .toLowerCase()
                .contains(searchText.value.toLowerCase()) ||
                app.job.companyName
                    .toLowerCase()
                    .contains(searchText.value.toLowerCase())))
        .toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'viewed':
        return Colors.blue;
      case 'applied':
        return Colors.blue.withOpacity(0.9);
      default:
        return AppColors.premiumGold;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green[50]!;
      case 'rejected':
        return Colors.red[50]!;
      case 'viewed':
        return Colors.blue[50]!;
      case 'applied':
        return Colors.blue[50]!;
      default:
        return AppColors.premiumGold.withOpacity(0.1);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'viewed':
        return Icons.visibility;
      case 'applied':
        return Icons.check;
      default:
        return Icons.info;
    }
  }

  String getStatusText(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class JobHistoryScreen extends StatelessWidget {
  JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobHistoryController>(
      init: JobHistoryController(Get.find()),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.premiumGold.withOpacity(0.1),
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.white),
          title: Text(
            'Application History',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        body: Obx(
          () => Column(
            children: [
              _buildSearchBar(controller),
              const SizedBox(height: 10),

              // Filter Chips
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filters.length,
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final isSelected =
                        controller.selectedFilter.value == filter['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          filter['label']!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.black : AppColors.white,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          controller.selectedFilter.value = filter['value']!;
                          controller.fetchApplications(refresh: true);
                        },
                        selectedColor: AppColors.premiumGold,
                        backgroundColor: AppColors.premiumGold.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: isSelected
                                  ? AppColors.premiumGold
                                  : AppColors.premiumGold.withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Applications Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.filteredApplications.length} Applications',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.premiumGold.withOpacity(0.7),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getStatusCountText(controller),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.premiumGold.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Applications List
              Expanded(
                child: controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.filteredApplications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: controller.scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                controller.filteredApplications.length +
                                    (controller.isLoadingMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index ==
                                  controller.filteredApplications.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final application =
                                  controller.filteredApplications[index];
                              return _buildApplicationCard(
                                  context, application, controller);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context,
      UserApplication application, JobHistoryController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.jobDescriptionScreen,arguments: application.job.slug);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold),
          boxShadow: [
            BoxShadow(
              color: AppColors.transparent,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    application.job.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusBgColor(application.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.getStatusIcon(application.status),
                        size: 14,
                        color: controller.getStatusColor(application.status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.getStatusText(application.status),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              controller.getStatusColor(application.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Company Name
            Text(
              application.job.companyName,
              style: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.8)),
            ),

            const SizedBox(height: 8),

            // Applied Date
            Text(
              'Applied: ${_formatDate(application.createdAt)}',
              style: GoogleFonts.poppins(
                color: AppColors.premiumGold.withOpacity(0.6),
                fontSize: 13,
              ),
            ),

            if (application.coverMessage != null &&
                application.coverMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                application.coverMessage!,
                style: GoogleFonts.poppins(
                  color: AppColors.premiumGold.withOpacity(0.6),
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.premiumGold.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No applications found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.premiumGold.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start applying to jobs to see them here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.premiumGold.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusCountText(JobHistoryController controller) {
    final accepted = controller.applications
        .where((a) => a.status == 'accepted')
        .length;
    final rejected = controller.applications
        .where((a) => a.status == 'rejected')
        .length;
    final viewed =
        controller.applications.where((a) => a.status == 'viewed').length;
    final applied =
        controller.applications.where((a) => a.status == 'applied').length;

    return 'Accept: $accepted • Reject: $rejected • View: $viewed • Apply: $applied' ;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildSearchBar(JobHistoryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.premiumGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.premiumGold.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SvgPicture.string(
              '''<svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 19C15.4183 19 19 15.4183 19 11C19 6.58172 15.4183 3 11 3C6.58172 3 3 6.58172 3 11C3 15.4183 6.58172 19 11 19Z" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M21 21L16.65 16.65" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>''',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: (value) => controller.searchText.value = value,
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.premiumGold.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
