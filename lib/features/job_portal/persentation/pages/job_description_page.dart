import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../route/app_pages.dart';
import '../../data/model/job_model.dart';
import '../controller/job_discription_controller.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';

class JobDescriptionScreen extends GetView<JobDescriptionController> {
  const JobDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: Colors.black),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          actions: [
            // Only show edit/delete for recruiters
            if (_isRecruiter()) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () => controller.editJob(),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.deleteJob(),
              ),
            ],
            const SizedBox(width: 8),
          ],
          title:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                job.companyName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
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
                      child: Divider(color: Colors.grey),
                    ),
                    _buildJobDescription(job),
                    if (job.requirements != null && job.requirements!.isNotEmpty)
                      _buildChipSection('Requirements', job.requirements!),
                    if (job.responsibilities != null && job.responsibilities!.isNotEmpty)
                      _buildBulletSection('Responsibilities', job.responsibilities!),
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
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job.companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
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
          //     border: Border.all(color: Colors.grey[300]!),
          //   ),
          //   child: Obx(() => IconButton(
          //     icon: Icon(
          //       controller.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
          //       color: Colors.black,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.17), // increase opacity
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
                image: DecorationImage(
                  image: NetworkImage(AppUrls.getFullImageUrl(job.companyLogo ?? job.employer.profilePhotoPath)),
                  fit: BoxFit.cover,
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
                      color: Colors.black,
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
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          job.location.isNotEmpty ? job.location : 'Remote',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      _buildTag('${job.currency} ${job.salaryMax}', Icons.attach_money_outlined),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.description,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, String content) {
    final List<String> items = content.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
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
                    border: Border.all(color: Colors.grey[300]!),
                    image: DecorationImage(
                      image: NetworkImage(AppUrls.getFullImageUrl(job.employer.profilePhotoPath)),
                      fit: BoxFit.cover,
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
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        job.employer.occupation ?? 'Recruiter',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 15),
            Row(
              children: [
                _buildCompanyStat('${job.employer.followersCount}', 'Followers'),
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
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildBulletSection(String title, String content) {
    final List<String> items = content.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
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
              color: Colors.black,
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
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${job.currency} ${job.salaryMin} - ${job.salaryMax}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: (){
              if (isRecruiter) {
                Get.toNamed(AppRoutes.applicantListScreen, arguments: job.id);
              } else {
                // Handle apply for applier
                controller.applyForJob();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isRecruiter ? 'View Applicant' : 'Apply Now',
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
    final type = AppUrls.selectedUserType.value;
    return type == 'recruiter';
  }
}
