/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobHistoryScreen extends StatelessWidget {
  JobHistoryScreen({super.key});

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  // Dummy data for job applications
  final List<Map<String, dynamic>> _jobApplications = [
    {
      'id': '1',
      'jobTitle': 'Senior Flutter Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'Remote',
      'salary': '₹12-18 LPA',
      'appliedDate': '2024-01-15',
      'status': 'applied',
      'statusText': 'Applied',
      'statusColor': Colors.blue,
      'bgColor': Colors.blue[50],
    },
    {
      'id': '2',
      'jobTitle': 'Full Stack Developer',
      'company': 'Digital Innovations',
      'location': 'Bangalore',
      'salary': '₹10-15 LPA',
      'appliedDate': '2024-01-10',
      'status': 'accepted',
      'statusText': 'Accepted',
      'statusColor': Colors.green,
      'bgColor': Colors.green[50],
    },
    {
      'id': '3',
      'jobTitle': 'Mobile App Developer',
      'company': 'StartUp Ventures',
      'location': 'Mumbai',
      'salary': '₹8-12 LPA',
      'appliedDate': '2024-01-05',
      'status': 'rejected',
      'statusText': 'Rejected',
      'statusColor': Colors.red,
      'bgColor': Colors.red[50],
    },
    {
      'id': '4',
      'jobTitle': 'React Native Developer',
      'company': 'App Masters',
      'location': 'Delhi',
      'salary': '₹9-14 LPA',
      'appliedDate': '2024-01-02',
      'status': 'applied',
      'statusText': 'Applied',
      'statusColor': Colors.blue,
      'bgColor': Colors.blue[50],
    },
    {
      'id': '5',
      'jobTitle': 'UI/UX Designer',
      'company': 'Creative Studios',
      'location': 'Hyderabad',
      'salary': '₹7-11 LPA',
      'appliedDate': '2023-12-28',
      'status': 'accepted',
      'statusText': 'Accepted',
      'statusColor': Colors.green,
      'bgColor': Colors.green[50],
    },
    {
      'id': '6',
      'jobTitle': 'Backend Developer',
      'company': 'Cloud Systems',
      'location': 'Pune',
      'salary': '₹11-16 LPA',
      'appliedDate': '2023-12-25',
      'status': 'rejected',
      'statusText': 'Rejected',
      'statusColor': Colors.red,
      'bgColor': Colors.red[50],
    },
    {
      'id': '7',
      'jobTitle': 'DevOps Engineer',
      'company': 'Infra Tech',
      'location': 'Chennai',
      'salary': '₹13-20 LPA',
      'appliedDate': '2023-12-20',
      'status': 'deleted',
      'statusText': 'Deleted',
      'statusColor': Colors.grey,
      'bgColor': Colors.grey[100],
    },
    {
      'id': '8',
      'jobTitle': 'Product Manager',
      'company': 'Growth Labs',
      'location': 'Gurgaon',
      'salary': '₹15-25 LPA',
      'appliedDate': '2023-12-15',
      'status': 'applied',
      'statusText': 'Applied',
      'statusColor': Colors.blue,
      'bgColor': Colors.blue[50],
    },
  ];

  // Filter chips data
  final List<Map<String, dynamic>> _filters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'applied', 'label': 'Applied'},
    {'value': 'accepted', 'label': 'Accepted'},
    {'value': 'rejected', 'label': 'Rejected'},
    {'value': 'deleted', 'label': 'Deleted'},
  ];

  @override
  Widget build(BuildContext context) {
    // Filter applications based on selected filter
    List<Map<String, dynamic>> filteredApplications = _jobApplications
        .where((app) => _selectedFilter == 'all' || app['status'] == _selectedFilter)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by job title or company...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    // In a StatefulWidget, you would call setState here
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                // In a StatefulWidget, you would call setState here to update search results
              },
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      filter['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      _selectedFilter = filter['value'];
                      // In a StatefulWidget, you would call setState here
                    },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Application Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredApplications.length} Applications',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  _getStatusCountText(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[200],
          ),

          // Applications List
          Expanded(
            child: filteredApplications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                final application = filteredApplications[index];
                return _buildApplicationCard(context,application);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, Map<String, dynamic> application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  application['jobTitle'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: application['bgColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(application['status']),
                      size: 14,
                      color: application['statusColor'],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      application['statusText'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: application['statusColor'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Company and Location
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                application['company'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                application['location'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Salary and Applied Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    application['salary'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Applied: ${_formatDate(application['appliedDate'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _viewJobDetails(context,application);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: Text(
                    'View Details',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (application['status'] != 'deleted')
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _deleteApplication(context,application['id']);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No applications found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyMessage(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (_selectedFilter != 'all')
            ElevatedButton(
              onPressed: () {
                _selectedFilter = 'all';
                // In a StatefulWidget, you would call setState here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View All Applications',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(String date) {
    // Simple date formatting
    final parts = date.split('-');
    if (parts.length == 3) {
      final day = parts[2];
      final month = _getMonthName(int.parse(parts[1]));
      final year = parts[0];
      return '$day $month $year';
    }
    return date;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'applied':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'deleted':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  String _getStatusCountText() {
    final applied = _jobApplications.where((a) => a['status'] == 'applied').length;
    final accepted = _jobApplications.where((a) => a['status'] == 'accepted').length;
    final rejected = _jobApplications.where((a) => a['status'] == 'rejected').length;

    return 'Applied: $applied • Accepted: $accepted • Rejected: $rejected';
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'applied':
        return 'You have no pending applications';
      case 'accepted':
        return 'No accepted applications yet';
      case 'rejected':
        return 'No rejected applications';
      case 'deleted':
        return 'No deleted applications';
      default:
        return 'Start applying to jobs to see them here';
    }
  }

  // Action Methods
  void _viewJobDetails(BuildContext context,Map<String, dynamic> application) {
    // Show job details dialog
    showDialog(
      context: context as BuildContext,
      builder: (context) => AlertDialog(
        title: Text(
          'Job Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                application['jobTitle'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                application['company'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: application['bgColor'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      application['statusText'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: application['statusColor'],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Applied: ${_formatDate(application['appliedDate'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow('Location', application['location']),
              _buildDetailRow('Salary', application['salary']),
              _buildDetailRow('Job ID', application['id']),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Status Description
              Text(
                _getStatusDescription(application['status']),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'applied':
        return 'Your application has been submitted successfully. The employer will review your profile.';
      case 'accepted':
        return 'Congratulations! Your application has been accepted. You will be contacted soon for next steps.';
      case 'rejected':
        return 'Unfortunately, your application was not selected for this position. Keep applying!';
      case 'deleted':
        return 'This application has been deleted from your history.';
      default:
        return '';
    }
  }

  void _deleteApplication(BuildContext context,String id) {
    // Show delete confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Application',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this application from your history?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would update the state here
              print('Deleted application: $id');
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}*/





import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'job_description_page.dart';

class JobHistoryController extends GetxController {
  var searchText = ''.obs;
  var selectedFilter = 'all'.obs;
  final TextEditingController searchController = TextEditingController();


  var jobApplications = <Map<String, dynamic>>[
    {
      'id': '1',
      'jobTitle': 'Senior Flutter Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'Remote',
      'salary': '₹12-18 LPA',
      'appliedDate': '2024-01-15',
      'status': 'applied',
      'statusText': 'Applied',
      'statusColor': Colors.blue,
      'bgColor': Colors.blue[50],
      'description':
      'We are looking for a skilled Flutter Developer to join our team and develop high-quality mobile apps.',
    },
    {
      'id': '2',
      'jobTitle': 'Full Stack Developer',
      'company': 'Digital Innovations',
      'location': 'Bangalore',
      'salary': '₹10-15 LPA',
      'appliedDate': '2024-01-10',
      'status': 'accepted',
      'statusText': 'Accepted',
      'statusColor': Colors.green,
      'bgColor': Colors.green[50],
      'description': 'Full Stack Developer needed for web and mobile projects.',
    },
    {
      'id': '3',
      'jobTitle': 'Mobile App Developer',
      'company': 'StartUp Ventures',
      'location': 'Mumbai',
      'salary': '₹8-12 LPA',
      'appliedDate': '2024-01-05',
      'status': 'rejected',
      'statusText': 'Rejected',
      'statusColor': Colors.red,
      'bgColor': Colors.red[50],
      'description': 'Develop innovative mobile applications in a fast-paced startup.',
    },
  ].obs;

  // Filtered list based on search and filter
  List<Map<String, dynamic>> get filteredApplications {
    return jobApplications
        .where((job) =>
    (selectedFilter.value == 'all' ||
        job['status'] == selectedFilter.value) &&
        (job['jobTitle']
            .toString()
            .toLowerCase()
            .contains(searchText.value.toLowerCase()) ||
            job['company']
                .toString()
                .toLowerCase()
                .contains(searchText.value.toLowerCase())))
        .toList();
  }

  final filters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'applied', 'label': 'Applied'},
    {'value': 'accepted', 'label': 'Accepted'},
    {'value': 'rejected', 'label': 'Rejected'},
  ];
}

class JobHistoryScreen extends StatelessWidget {
  JobHistoryScreen({super.key});

  final JobHistoryController controller = Get.put(JobHistoryController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
      body: Obx(
            () => Column(
          children: [
            // Search Bar
           /* Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => controller.searchText.value = value,
                decoration: InputDecoration(
                  hintText: 'Search by job title or company...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      controller.searchText.value = '';
                    },
                  )
                      : null,
                ),
              ),
            ),*/

            _buildSearchBar(controller),
            SizedBox(height: 10,),

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
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) =>
                      controller.selectedFilter.value = filter['value']!,
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color:
                            isSelected ? Colors.black : Colors.grey[300]!),
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
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    _getStatusCountText(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Applications List
            Expanded(
              child: controller.filteredApplications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredApplications.length,
                itemBuilder: (context, index) {
                  final application =
                  controller.filteredApplications[index];
                  return _buildApplicationCard(context, application);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(
      BuildContext context, Map<String, dynamic> application) {
    return GestureDetector(
      onTap: (){
        Get.to(JobDescriptionScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
                    application['jobTitle'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: application['bgColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(application['status']),
                        size: 14,
                        color: application['statusColor'],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        application['statusText'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: application['statusColor'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Company, Location, Salary
            Text(
              '${application['company']} • ${application['location']}',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              'Salary: ${application['salary']}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 8),

            // Short Description
            Text(
              application['description'],
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // View Details Button
         /*   Center(
              child: ElevatedButton(
                onPressed: () => _viewJobDetails(context, application),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),*/
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
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No applications found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start applying to jobs to see them here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStatusCountText() {
    final applied = controller.jobApplications
        .where((a) => a['status'] == 'applied')
        .length;
    final accepted = controller.jobApplications
        .where((a) => a['status'] == 'accepted')
        .length;
    final rejected = controller.jobApplications
        .where((a) => a['status'] == 'rejected')
        .length;

    return 'Applied: $applied • Accepted: $accepted • Rejected: $rejected';
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'applied':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'deleted':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  void _viewJobDetails(BuildContext context, Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          application['jobTitle'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application['company'],
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              application['description'],
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(application['location'],
                    style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(application['salary'],
                    style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.black)),
          )
        ],
      ),
    );
  }


  Widget _buildSearchBar(JobHistoryController controller) {
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

}

