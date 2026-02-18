import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/job_portal_controller.dart';
import '../widgets/profile_drawer.dart';
import 'job_description_page.dart';

class JobSearchScreen extends StatelessWidget {
  JobSearchScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final JobController controller = Get.put(JobController());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Profile
            _buildAppBar(),

            // Search Bar
            _buildSearchBar(controller),

            // Company Logos Horizontal List
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 16),
              child: Align(
                alignment: Alignment.topLeft,
                  child: Text("Recruiter Connection",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w700),)),
            ),
            _buildCompanyLogos(controller),

            // Tab Bar for Urgent/Recent
            _buildTabBar(controller),

            // Tab View Content
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  // Urgent Needed Tab
                  _buildUrgentJobsTab(controller),

                  // Recent Jobs Tab
                  _buildRecentJobsTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Profile Section - Clickable
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alex Johnson',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Senior UI/UX Designer',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bell Icon with Notification
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: SvgPicture.string(
                    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12 22C13.1 22 14 21.1 14 20H10C10 21.1 10.9 22 12 22ZM18 16V11C18 7.93 16.37 5.36 13.5 4.68V4C13.5 3.17 12.83 2.5 12 2.5C11.17 2.5 10.5 3.17 10.5 4V4.68C7.64 5.36 6 7.92 6 11V16L4 18V19H20V18L18 16Z" fill="black"/>
                    </svg>''',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(JobController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!),
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
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies, keywords...',
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

  Widget _buildCompanyLogos(JobController controller) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        itemCount: controller.companies.length,
        itemBuilder: (context, index) {
          final company = controller.companies[index];
          return
         //   Obx(() =>
                Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => controller.selectCompany(index),
                  // decoration: BoxDecoration(
                  //   color: controller.selectedCompanyIndex.value == index
                  //       ? Colors.grey[900]
                  //       : Colors.white,
                  //   borderRadius: BorderRadius.circular(12),
                  //   border: Border.all(
                  //     color: controller.selectedCompanyIndex.value == index
                  //         ? Colors.black
                  //         : Colors.grey[300]!,
                  //     width: 2,
                  //   ),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.grey.withOpacity(0.1),
                  //       blurRadius: 10,
                  //       offset: const Offset(0, 4),
                  //     ),
                  //   ],
                  // ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Company Logo Placeholder
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: Colors.grey[200],
                          // image: DecorationImage(
                          //   image: NetworkImage(company.logo),
                          //   fit: BoxFit.cover,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image(
                            image: NetworkImage(company.logo),
                            fit: BoxFit.cover,
                          ),
                        ),
                        //),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        company.name,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: controller.selectedCompanyIndex.value == index
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

              ),
           // ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(JobController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        controller: controller.tabController,
       // indicatorColor: Colors.black,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.zero, // 👈 NO CURVE
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [Tab(text: 'Urgent Needed  🔥'), Tab(text: ' Recent')],
      ),
    );
  }

  Widget _buildUrgentJobsTab(JobController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.urgentJobs.length,
      itemBuilder: (context, index) {
        final job = controller.urgentJobs[index];
        return _buildJobCard(job, true);
      },
    );
  }

  Widget _buildRecentJobsTab(JobController controller) {
    return Column(
      children: [
        // Filter Chips
        SizedBox(
          height: 60,
          child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildFilterChip('All', controller.selectedFilter.value == 'All'),
              _buildFilterChip(
                'Full Time',
                controller.selectedFilter.value == 'Full Time',
              ),
              _buildFilterChip(
                'Part Time',
                controller.selectedFilter.value == 'Part Time',
              ),
              _buildFilterChip(
                'Remote',
                controller.selectedFilter.value == 'Remote',
              ),
              _buildFilterChip(
                'Contract',
                controller.selectedFilter.value == 'Contract',
              ),
            ],
          ),
          )

        ),

        // Job List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.recentJobs.length,
            itemBuilder: (context, index) {
              final job = controller.recentJobs[index];
              return _buildJobCard(job, false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        showCheckmark: false,
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          final controller = Get.find<JobController>();
          controller.selectedFilter.value = selected ? label : 'All';
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 👈 yaha kam / zyada control
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.grey[400]!,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job, bool isUrgent) {
    return
      InkWell(
      onTap: (){
        Get.to(() => JobDescriptionScreen());
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
                        image: NetworkImage(job.companyLogo),
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
                          job.position,
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
                              '💼 ${job.type}',
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
                  // Urgent Badge
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: GoogleFonts.poppins(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'Urgent',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
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
                          '${job.daysLeft} days left',
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
                    '💰 \$${job.salary}k/yr',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
      
                  const SizedBox(width: 12),
      
                  // Apply Button
                  Container(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


