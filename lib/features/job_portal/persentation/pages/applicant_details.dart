import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_urls.dart';
import '../../data/model/job_model.dart';
import '../controller/applicant_controller.dart';

class ApplicantDetail extends GetView<ApplicantController> {
  final int applicationId;

  const ApplicantDetail({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    final application = controller.getApplicantById(applicationId);

    if (application == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1A2E3F)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'Application not found',
            style: TextStyle(color: Color(0xFF1A2E3F)),
          ),
        ),
      );
    }

    final applicant = application.applicant;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          applicant.name,
          style: const TextStyle(
            color: Color(0xFF1A2E3F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1A2E3F)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: applicant.profilePhotoPath != null 
                      ? NetworkImage(AppUrls.imageurl+applicant.profilePhotoPath!)
                      : null,
                    child: applicant.profilePhotoPath == null
                      ? Text(
                          applicant.name
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join(),
                          style: const TextStyle(
                            color: Color(0xFF1A2E3F),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    applicant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2E3F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    applicant.occupation ?? 'Applicant',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  /// Applied Date Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E3F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Applied on ${_formatDate(application.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Sections
            _buildSection(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _buildDetailRow(Icons.email_outlined, 'Email', applicant.email),
                _buildDetailRow(Icons.phone_outlined, 'Phone', applicant.phone),
                _buildDetailRow(Icons.location_on_outlined, 'Location', applicant.countryCode),
                _buildDetailRow(Icons.work_outline, 'Occupation', applicant.occupation ?? 'N/A'),
              ],
            ),

            if (applicant.bio != null && applicant.bio!.isNotEmpty)
              _buildSection(
                title: 'About Applicant',
                icon: Icons.info_outline,
                children: [
                  Text(
                    applicant.bio!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

            _buildSection(
              title: 'Application Details',
              icon: Icons.description_outlined,
              children: [
                _buildDetailRow(Icons.stars_outlined, 'Status', application.status.toUpperCase()),
                const SizedBox(height: 12),
                if (application.coverMessage != null && application.coverMessage!.isNotEmpty) ...[
                  const Text(
                    'Cover Letter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2E3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      application.coverMessage!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (application.resumePath != null)
                  Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 24, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Resume.pdf',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A2E3F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                     // _cvIconButton(
                      //   icon: Icons.visibility_outlined,
                      //   color: Colors.white,
                      //   background: Colors.grey.shade300,
                      //   onPressed: () {},
                      // ),
                      const SizedBox(width: 8),
                      _cvIconButton(
                        icon: Icons.download_outlined,
                        color: Colors.white,
                        background: const Color(0xFF1A2E3F),
                        onPressed: () {
                          controller.downloadResume(
                            application.id, 
                            "resume_${applicant.name.replaceAll(' ', '_')}.pdf"
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),

            /// 🔹 Status Badge (Reactive)
            Obx(() {
              final currentApp = controller.getApplicantById(applicationId);
              if (currentApp == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentApp.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentApp.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            /// 🔹 Status Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Application Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2E3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => controller.isLoading.value 
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusActionButton(
                        context, 
                        'shortlisted', 
                        Colors.blue.shade700,
                        Icons.star_outline,
                      ),
                      _statusActionButton(
                        context, 
                        'accepted', 
                        Colors.green.shade700,
                        Icons.check_circle_outline,
                      ),
                      _statusActionButton(
                        context, 
                        'rejected', 
                        Colors.red.shade700,
                        Icons.cancel_outlined,
                      ),
                      _statusActionButton(
                        context, 
                        'viewed', 
                        Colors.orange.shade700,
                        Icons.remove_red_eye_outlined,
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------- Helper Widgets -----------------

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A2E3F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2E3F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A2E3F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cvIconButton({
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _statusActionButton(
    BuildContext context, 
    String status, 
    Color color,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => controller.updateStatus(applicationId, status),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'shortlisted':
        return Colors.blue.shade600;
      case 'viewed':
        return Colors.orange.shade600;
      default:
        return const Color(0xFF1A2E3F);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
