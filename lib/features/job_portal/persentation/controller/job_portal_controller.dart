import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobController extends GetxController with GetSingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  late final TabController tabController;

  final RxInt selectedCompanyIndex = 0.obs;
  final RxString selectedFilter = 'All'.obs;

  final List<Company> companies = [
    Company('Google', 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png'),
    Company('Apple', 'https://cdn-icons-png.flaticon.com/512/731/731985.png'),
    Company('Microsoft', 'https://cdn-icons-png.flaticon.com/512/732/732221.png'),
    Company('Amazon', 'https://cdn-icons-png.flaticon.com/512/731/731966.png'),
    Company('Facebook', 'https://cdn-icons-png.flaticon.com/512/733/733547.png'),
  ];

  final List<Job> urgentJobs = [
    Job(
      companyName: 'Google',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
      position: 'Senior UX Designer',
      location: 'Lucknow',
      type: 'Full Time',
      description: 'We\'re looking for a Senior UX Designer to join our team and help create amazing user experiences for millions of users worldwide.',
      daysLeft: 2,
      salary: 180,
    ),
    Job(
      companyName: 'Apple',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/731/731985.png',
      position: 'iOS Developer',
      location: 'Mumbai',
      type: 'Full Time',
      description: 'Join our iOS development team to build next-generation applications for iPhone, iPad, and Apple Watch.',
      daysLeft: 1,
      salary: 160,
    ),
  ];

  final List<Job> recentJobs = [
    Job(
      companyName: 'Microsoft',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/732/732221.png',
      position: 'Cloud Architect',
      location: 'Lucknow',
      type: 'Remote',
      description: 'Design and implement cloud solutions using Azure. Must have 5+ years experience in cloud architecture.',
      daysLeft: 7,
      salary: 200,
    ),
    Job(
      companyName: 'Amazon',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/731/731966.png',
      position: 'Mumbai',
      location: 'Seattle, WA',
      type: 'Full Time',
      description: 'Analyze large datasets and build machine learning models to improve customer experience.',
      daysLeft: 5,
      salary: 170,
    ),
    Job(
      companyName: 'Netflix',
      companyLogo: 'https://cdn-icons-png.flaticon.com/512/732/732228.png',
      position: 'Content Strategist',
      location: 'Los Gatos, CA',
      type: 'Contract',
      description: 'Develop content strategies for original programming and global content distribution.',
      daysLeft: 10,
      salary: 150,
    ),
  ];

  void selectCompany(int index) {
    selectedCompanyIndex.value = index;
    // Here you would typically filter jobs based on selected company
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }
}

class Company {
  final String name;
  final String logo;

  Company(this.name, this.logo);
}

class Job {
  final String companyName;
  final String companyLogo;
  final String position;
  final String location;
  final String type;
  final String description;
  final int daysLeft;
  final double salary;

  Job({
    required this.companyName,
    required this.companyLogo,
    required this.position,
    required this.location,
    required this.type,
    required this.description,
    required this.daysLeft,
    required this.salary,
  });
}