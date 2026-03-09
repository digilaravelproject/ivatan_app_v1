import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/features/job_portal/persentation/controller/job_controller.dart';
import 'package:i_vatan_app/route/app_pages.dart';
import '../../../../db/shared_pref_manager.dart';
import '../../data/model/job_model.dart';

class JobSearchScreen extends GetView<JobController> {
  JobSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCompanyLogos(),
            const SizedBox(height: 10),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildAllJobsTab(),
                  _buildUrgentJobsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage(SharedPrefManager().user!.profilePhotoPath.toString()),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${SharedPrefManager().user!.name}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                SharedPrefManager().user!.occupation.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Filter Icon replacing Bell
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Stack(
              children: [
                Obx(() => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    color: controller.isFilterApplied.value ? Colors.black : Colors.white,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.filter_list,
                      color: controller.isFilterApplied.value ? Colors.white : Colors.black,
                      size: 24,
                    ),
                  ),
                )),
                Obx(() => controller.isFilterApplied.value
                  ? Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
                onChanged: (value) => controller.searchQ.value = value,
                onSubmitted: (value) => controller.fetchJobs(),
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies, keywords...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Obx(() => controller.searchQ.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchQ.value = '';
                            controller.fetchJobs();
                          },
                        )
                      : const SizedBox.shrink()),
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

  Widget _buildCompanyLogos() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        itemCount: controller.companies.length,
        itemBuilder: (context, index) {
          final company = controller.companies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => controller.selectCompany(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      color: Colors.grey[200],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: NetworkImage(company.logo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    company.name,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: controller.selectedCompanyIndex.value == index
                          ? Colors.blue
                          : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TabBar(
        controller: controller.tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.zero,
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
        tabs: const [Tab(text: 'All Jobs'), Tab(text: 'Urgent Needed  🔥')],
      ),
    );
  }

  Widget _buildUrgentJobsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final urgentJobs = controller.jobList.where((j) => j.isUrgentActive).toList();

      if (urgentJobs.isEmpty) {
        return const Center(child: Text("No urgent jobs found"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: urgentJobs.length,
        itemBuilder: (context, index) {
          final job = urgentJobs[index];
          return _buildJobCard(job, true);
        },
      );
    });
  }

  Widget _buildAllJobsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final allJobs = controller.jobList;

      if (allJobs.isEmpty) {
        return const Center(child: Text("No jobs found"));
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: allJobs.length + (controller.isMoreLoading.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < allJobs.length) {
            final job = allJobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildJobCard(job, job.isUrgentActive),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
        },
      );
    });
  }

  Widget _buildJobCard(JobModel job, bool isUrgent) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.jobDescriptionScreen, arguments: job.slug);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: ClipOval(
                      child: (job.companyLogo != null && job.companyLogo!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: AppUrls.getFullImageUrl(job.companyLogo),
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.business,
                                size: 24,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.business,
                              size: 24,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.companyName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          job.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '📍 ${job.location}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '💼 ${job.employmentType}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: GoogleFonts.poppins(fontSize: 10)),
                          const SizedBox(width: 2),
                          Text(
                            'Urgent',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text('📅', style: GoogleFonts.poppins(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          _getPostedLabel(job.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '💰 ${job.currency} ${job.salaryMax}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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

  String _getPostedLabel(String createdAt) {
    try {
      final posted = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final postedDay = DateTime(posted.year, posted.month, posted.day);
      final diff = today.difference(postedDay).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return '$diff days ago';
    } catch (_) {
      return 'Recently';
    }
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: Text(
                      'Clear All',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildFilterLabel('Location'),
              _buildFilterTextField(
                hint: 'Enter City',
                initialValue: controller.filterLocation.value,
                onChanged: (val) => controller.filterLocation.value = val,
              ),
              
              const SizedBox(height: 16),
              _buildFilterLabel('Country'),
              _buildFilterTextField(
                hint: 'Enter Country',
                initialValue: controller.filterCountry.value,
                onChanged: (val) => controller.filterCountry.value = val,
              ),
              
              const SizedBox(height: 16),
              _buildFilterLabel('Employment Type'),
              _buildEmploymentTypeChips(),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterLabel('Remote Only'),
                  Obx(() => Switch(
                    value: controller.filterIsRemote.value,
                    onChanged: (val) => controller.filterIsRemote.value = val,
                    activeColor: Colors.black,
                  )),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildFilterLabel('Salary Range'),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterTextField(
                      hint: 'Min',
                      initialValue: controller.filterSalaryMin.value,
                      onChanged: (val) => controller.filterSalaryMin.value = val,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('-'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterTextField(
                      hint: 'Max',
                      initialValue: controller.filterSalaryMax.value,
                      onChanged: (val) => controller.filterSalaryMax.value = val,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFilterTextField({
    required String hint,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _buildEmploymentTypeChips() {
    final types = [
      {'label': 'Full Time', 'value': 'full_time'},
      {'label': 'Part Time', 'value': 'part_time'},
      {'label': 'Contract', 'value': 'contract'},
      {'label': 'Freelance', 'value': 'freelance'},
    ];

    return Obx(() => Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = controller.filterEmploymentType.value == type['value'];
        return ChoiceChip(
          label: Text(type['label']!),
          selected: isSelected,
          onSelected: (selected) {
            controller.filterEmploymentType.value = selected ? type['value']! : '';
          },
          selectedColor: Colors.black,
          labelStyle: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        );
      }).toList(),
    ));
  }
}