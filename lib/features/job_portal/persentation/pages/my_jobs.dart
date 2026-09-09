import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../route/app_pages.dart';
import '../../../../core/network/app_urls.dart';
import '../../data/model/job_model.dart';
import '../controller/recruiter_jobs_controller.dart';

class MyCreatedJobScreen extends GetView<RecruiterJobsController> {
  const MyCreatedJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'My Created Jobs',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
              if (controller.isLoading.value && controller.jobs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter jobs by search text
              final filteredJobs = controller.jobs.where((job) {
                return job.title.toLowerCase().contains(controller.searchText.value.toLowerCase());
              }).toList();

              if (filteredJobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off_outlined, size: 64, color: AppColors.premiumGold.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchText.value.isEmpty ? "No jobs found" : "No jobs match your search",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.premiumGold.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  return _buildJobCard(filteredJobs[index]);
                },
              );
            }),
                Obx(() {
                  if (controller.isMoreLoading.value && controller.searchText.value.isEmpty) {
                    return Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.premiumGold.withOpacity(0.4)),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.jobDescriptionScreen, arguments: job.slug);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: AppUrls.getFullImageUrl(job.companyLogo),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.premiumGold.withOpacity(0.1),
                        child: Icon(Icons.business, color: AppColors.premiumGold),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.premiumGold.withOpacity(0.1),
                        child: Icon(Icons.business, color: AppColors.premiumGold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Company Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          job.companyName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.premiumGold.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.premiumGold.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              job.location,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.premiumGold.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.work_outline, size: 14, color: AppColors.premiumGold.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              job.employmentType,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.premiumGold.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Urgent Badge
                  if (job.isUrgentActive == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Urgent',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              
              const Divider(),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salary Range',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.premiumGold.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        '${job.currency} ${job.salaryMin ?? 'N/A'} - ${job.salaryMax ?? 'N/A'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.applicantListScreen, arguments: job.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.transparent,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'View Applicants (${job.applicationsCount ?? 0})',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(RecruiterJobsController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: (value) {
            controller.searchText.value = value;
          },
          decoration: InputDecoration(
            hintText: 'Search by job title...',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.premiumGold.withOpacity(0.4),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.white),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                controller.searchController.clear();
                controller.searchText.value = '';
                controller.isMoreLoading.value = false;
              }
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
        ),
      ),
    );
  }
}
