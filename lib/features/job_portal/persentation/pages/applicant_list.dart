import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../../data/model/job_model.dart';
import '../controller/applicant_controller.dart';
import '../../../../route/app_pages.dart';

class ApplicantList extends GetView<ApplicantController> {
  const ApplicantList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text(
          'Applicants',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.applicants.isEmpty) {
          return const Center(child: Text('No applicants found for this job.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.applicants.length,
          itemBuilder: (context, index) {
            final application = controller.applicants[index];
            return _buildApplicantCard(context, application);
          },
        );
      }),
    );
  }

  Widget _buildApplicantCard(BuildContext context, JobApplication application) {
    final applicant = application.applicant;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.premiumGold, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Get.toNamed(AppRoutes.applicantDetailsScreen, arguments: application.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Top Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.premiumGold,
                  backgroundImage: applicant.profilePhotoPath != null 
                    ? NetworkImage(AppUrls.imageurl+applicant.profilePhotoPath!)
                    : null,
                  child: applicant.profilePhotoPath == null
                    ? Text(
                        applicant.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      )
                    : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        applicant.occupation ?? 'Applicant',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.premiumGold,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔥 Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(application.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: AppColors.premiumGold.withOpacity(0.2), height: 1),
            const SizedBox(height: 14),

            /// 🔹 Info Row
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: applicant.email,
                ),
                const SizedBox(width: 16),
                _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: _getDaysAgo(application.createdAt),
                ),
              ],
            ),
            
            if (application.coverMessage != null && application.coverMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                application.coverMessage!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.premiumGold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.premiumGold,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.premiumGold,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'viewed': return Colors.blue;
      case 'shortlisted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getDaysAgo(String dateStr) {
    try {
      final appliedDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(appliedDate).inDays;

      if (difference == 0) return 'today';
      if (difference == 1) return 'yesterday';
      return '$difference days ago';
    } catch (e) {
      return 'Recently';
    }
  }
}