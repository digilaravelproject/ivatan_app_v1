import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/helper/profile_permission_manager.dart';
import '../../../../route/app_pages.dart';
import '../../data/model/job_model.dart';
import '../controller/job_discription_controller.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';

import 'occupation_form_page.dart';

class JobDescriptionScreen extends GetView<JobDescriptionController> {
  const JobDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: AppColors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.white),
          ),
        );
      }

      final job = controller.job.value;
      if (job == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Job not found')),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Only show edit/delete for recruiters
            if (_isRecruiter() && job.isMine) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.white),
                onPressed: () => controller.editJob(),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.deleteJob(),
              ),
            ],
            const SizedBox(width: 8),
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                job.companyName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.premiumGold.withOpacity(0.6),
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _buildHeader(job),
                    _buildJobInfo(job),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: AppColors.premiumGold),
                    ),
                    _buildJobDescription(job),
                    if (job.requirements != null &&
                        job.requirements!.isNotEmpty)
                      _buildChipSection('Requirements', job.requirements!),
                    if (job.responsibilities != null &&
                        job.responsibilities!.isNotEmpty)
                      _buildBulletSection(
                        'Responsibilities',
                        job.responsibilities!,
                      ),
                    // _buildCompanyInfo(job),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: _buildApplyButton(job),
              // ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildApplyButton(job),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(JobModel job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job.companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.premiumGold.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(width: 12),
          // Container(
          //   width: 45,
          //   height: 45,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(color: AppColors.premiumGold.withOpacity(0.3)),
          //   ),
          //   child: Obx(() => IconButton(
          //     icon: Icon(
          //       controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
          //       color: AppColors.white,
          //     ),
          //     onPressed: () => controller.toggleBookmark(),
          //   )),
          // ),
        ],
      ),
    );
  }

  Widget _buildJobInfo(JobModel job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: AppColors.premiumGold),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.transparent, // increase opacity
              blurRadius: 12, // increase blur
              spreadRadius: 2,
              offset: const Offset(0, 6), // better offset
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.premiumGold.withOpacity(0.1),
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: AppUrls.getFullImageUrl(
                    job.companyLogo ?? job.employer.profilePhotoPath,
                  ),
                  fit: BoxFit.cover,
                  errorWidget:
                      (context, url, error) => const Icon(
                        Icons.business,
                        size: 24,
                        color: AppColors.premiumGold,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          job.companyName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.premiumGold.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.premiumGold.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          job.location.isNotEmpty ? job.location : 'Remote',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.premiumGold.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildTag(job.employmentType, Icons.work_outline),
                      _buildTag(
                        '${job.currency} ${job.salaryMax}',
                        Icons.attach_money_outlined,
                      ),
                      if (job.isRemote)
                        _buildTag('Remote', Icons.home_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.premiumGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.premiumGold.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.premiumGold.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescription(JobModel job) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Description',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.description,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: AppColors.premiumGold.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, String content) {
    final List<String> items =
        content
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                items.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.premiumGold,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(JobModel job) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.premiumGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.premiumGold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.premiumGold.withOpacity(0.1),
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: AppUrls.getFullImageUrl(
                        job.employer.profilePhotoPath,
                      ),
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) => const Icon(
                            Icons.business,
                            size: 30,
                            color: AppColors.premiumGold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.employer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        job.employer.occupation ?? 'Recruiter',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.premiumGold.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (job.employer.bio != null) ...[
              const SizedBox(height: 15),
              Text(
                job.employer.bio!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.premiumGold.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 15),
            Row(
              children: [
                _buildCompanyStat(
                  '${job.employer.followersCount}',
                  'Followers',
                ),
                const SizedBox(width: 20),
                _buildCompanyStat('${job.employer.postsCount}', 'Posts'),
                const SizedBox(width: 20),
                _buildCompanyStat(job.status, 'Status'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.premiumGold.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletSection(String title, String content) {
    final List<String> items =
        content
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.premiumGold.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildApplyButton(JobModel job) {
    final isRecruiter = _isRecruiter();
    final isApplied = job.isApplied;
    final canViewApplicants = isRecruiter && job.isMine;

    // Recruiter jo is job ka owner nahi hai → koi button nahi dikhana
    if (isRecruiter && !job.isMine) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border(top: BorderSide(color: AppColors.premiumGold)),
          boxShadow: [
            BoxShadow(
              color: AppColors.transparent,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Salary Range',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.premiumGold.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${job.currency} ${job.salaryMin} - ${job.salaryMax}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border(top: BorderSide(color: AppColors.premiumGold)),
        boxShadow: [
          BoxShadow(
            color: AppColors.transparent,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Salary Range',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.premiumGold.withOpacity(0.6),
                  ),
                ),
                Text(
                  '${job.currency} ${job.salaryMin} - ${job.salaryMax}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          /*ElevatedButton(
            onPressed: () {
              if (canViewApplicants) {
                Get.toNamed(AppRoutes.applicantListScreen, arguments: job.id);
              } else {
                // Applier → apply flow
                Get.to(() => const ResumeFormScreen(), arguments: {'jobId': job.id});
              }
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.transparent,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              canViewApplicants ? 'View Applicants' : 'Apply Now',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),*/
          ElevatedButton(
            onPressed:
                (!isRecruiter && isApplied)
                    ? null // disable क्लिक
                    : () {
                      if (canViewApplicants) {
                        Get.toNamed(
                          AppRoutes.applicantListScreen,
                          arguments: job.id,
                        );
                      } else {
                        Get.to(
                          () => const ResumeFormScreen(),
                          arguments: {'jobId': job.id},
                        );
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (!isRecruiter && isApplied)
                      ? AppColors.premiumGold.withOpacity(0.5) // disabled look
                      : AppColors.premiumGold,
              foregroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              (!isRecruiter && isApplied)
                  ? 'Applied'
                  : (canViewApplicants ? 'View Applicants' : 'Apply Now'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isRecruiter() {
    return ProfilePermissionManager.isProfileActive(ProfileType.employer);
    //    SharedPrefManager().user?.isEmployer ?? false;
  }
}
