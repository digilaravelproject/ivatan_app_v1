import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../route/app_pages.dart';
import '../../data/model/job_model.dart';
import '../controller/job_controller.dart';


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
          'My Jobs',
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
                  // InkWell(
                  //   onTap: () {
                  //     Get.toNamed(AppRoutes.applicantListScreen, arguments: job.id);
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 20,
                  //       vertical: 10,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.black,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Text(
                  //       'Apply',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
