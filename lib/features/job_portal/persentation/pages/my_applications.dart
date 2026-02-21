import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../route/app_pages.dart';
import '../../data/model/job_model.dart';
import '../controller/job_controller.dart';

// Separate controller class to hold job data
/*class JobApplicationController {
  // List of job applications with status
  static final List<Map<String, dynamic>> jobApplications = [
    {
      'jobTitle': 'Frontend Developer',
      'company': 'Tech Solutions Inc.',
      'status': 'viewed',
      'appliedDate': '2024-01-15',
    },
    {
      'jobTitle': 'Flutter Developer',
      'company': 'AppCraft',
      'status': 'reject',
      'appliedDate': '2024-01-10',
    },
    {
      'jobTitle': 'UI/UX Designer',
      'company': 'Creative Studio',
      'status': 'accept',
      'appliedDate': '2024-01-05',
    },
    {
      'jobTitle': 'Backend Engineer',
      'company': 'CloudNine',
      'status': 'viewed',
      'appliedDate': '2024-01-18',
    },
    {
      'jobTitle': 'Product Manager',
      'company': 'InnovateHub',
      'status': 'reject',
      'appliedDate': '2024-01-12',
    },
    {
      'jobTitle': 'Data Analyst',
      'company': 'DataMind',
      'status': 'accept',
      'appliedDate': '2024-01-08',
    },
    {
      'jobTitle': 'DevOps Specialist',
      'company': 'SysOps Pro',
      'status': 'viewed',
      'appliedDate': '2024-01-20',
    },
    {
      'jobTitle': 'QA Tester',
      'company': 'QualityFirst',
      'status': 'accept',
      'appliedDate': '2024-01-03',
    },
    {
      'jobTitle': 'Technical Writer',
      'company': 'DocuMint',
      'status': 'viewed',
      'appliedDate': '2024-01-17',
    },
    {
      'jobTitle': 'Sales Executive',
      'company': 'GrowthCorp',
      'status': 'reject',
      'appliedDate': '2024-01-14',
    },
  ];

  // Helper method to get color for status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'accept':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'viewed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get icon for status
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'accept':
        return Icons.check_circle;
      case 'reject':
        return Icons.cancel;
      case 'viewed':
        return Icons.visibility;
      default:
        return Icons.help;
    }
  }

  // Helper method to format status text
  static String getStatusText(String status) {
    switch (status) {
      case 'accept':
        return 'Accepted';
      case 'reject':
        return 'Rejected';
      case 'viewed':
        return 'Viewed';
      default:
        return status;
    }
  }
}

// Main screen widget - Stateless
class MyAppliedJobScreen extends StatelessWidget {
  const MyAppliedJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Application Status'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.withOpacity(0.2), Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: JobApplicationController.jobApplications.length,
          itemBuilder: (context, index) {
            final job = JobApplicationController.jobApplications[index];
            return _buildJobCard(job);
          },
        ),
      ),
    );
  }

  // Widget to build individual job card
  Widget _buildJobCard(Map<String, dynamic> job) {
    String status = job['status'];
    Color statusColor = JobApplicationController.getStatusColor(status);
    IconData statusIcon = JobApplicationController.getStatusIcon(status);
    String statusText = JobApplicationController.getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12, right: 10, left: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job['jobTitle'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business_center, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  job['company'],
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  "Lucknow",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Applied: ${job['appliedDate']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/








class MyCreatedJobScreen extends GetWidget<JobController> {
  const MyCreatedJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Application History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.jobList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.jobList.isEmpty) {
                return const Center(child: Text("No jobs found"));
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.jobList.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < controller.jobList.length) {
                    final job = controller.jobList[index];
                    return _buildJobCard(job);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}



Widget _buildJobCard(JobModel job,) {
  return
    InkWell(
      onTap: (){
        Get.toNamed(AppRoutes.jobDescriptionScreen, arguments: job.slug);
      },
      child:
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Company Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // border: Border.all(color: Colors.grey[300]!),
                      image: DecorationImage(
                        image: NetworkImage("https://cdn-icons-png.flaticon.com/512/731/731985.png"),
                        fit: BoxFit.cover,
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
                          job.companyName,
                          style: GoogleFonts.poppins(
                            // fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          job.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '📍 ${job.location}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '💼 ${job.employmentType}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 10),

              // Job Description
              Text(
                job.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Footer with Days Left and Apply Button
              Row(
                children: [
                  // Days Left
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text('⏳', style: GoogleFonts.poppins(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${7} days left',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Salary
                  Text(
                    '💰 \$${job.salaryMax}k/yr',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Apply Button
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.applicantListScreen, arguments: job.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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


Widget _buildSearchBar(JobController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
    child: Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[400]!),
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
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}
