
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/job_disciption_model.dart';

class JobDescriptionController extends GetxController {
  // List of all jobs
  final RxList<Job> jobs = <Job>[].obs;

  // Currently selected job index
  final RxInt selectedJobIndex = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    loadJobs();
  }

  // Load jobs data
  Future<void> loadJobs() async {
    isLoading.value = true;

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Add sample jobs data
    jobs.assignAll([
      Job(
        id: 1,
        companyName: 'Google',
        companyLogo: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
        position: 'Senior UX Designer',
        location: 'Mountain View, CA',
        type: 'Full Time',
        description: 'We are looking for a Senior UX Designer to join our team and lead the design of innovative products that impact millions of users worldwide. The ideal candidate will have a strong portfolio showcasing user-centered design solutions and experience working in agile environments.',
        daysLeft: 2,
        salary: 180,
        experience: '5+ years',
        workingHours: '9 AM - 6 PM',
        vacancies: 3,
        skillsRequired: [
          'UI/UX Design',
          'Figma',
          'Adobe XD',
          'Prototyping',
          'User Research',
          'Wireframing',
          'Design Systems',
        ],
        requirements: [
          'Bachelor\'s degree in Design or related field',
          '5+ years of UX design experience',
          'Strong portfolio of design projects',
          'Experience with design tools like Figma, Sketch, or Adobe XD',
          'Knowledge of HTML/CSS; JavaScript is a plus',
          'Excellent communication and presentation skills',
        ],
        benefits: [
          'Health Insurance',
          'Remote Work',
          'Flexible Hours',
          'Bonus',
          'Learning Budget',
          'Gym Membership',
        ],
        companyIndustry: 'Technology',
        companyDescription: 'Google is a multinational technology company specializing in Internet-related services and products, which include online advertising technologies, search engine, cloud computing, software, and hardware.',
        companySize: '150000',
        companyFounded: '1998',
        companyLocation: 'Global',
      ),
      Job(
        id: 2,
        companyName: 'Apple',
        companyLogo: 'https://cdn-icons-png.flaticon.com/512/731/731985.png',
        position: 'iOS Developer',
        location: 'Cupertino, CA',
        type: 'Full Time',
        description: 'Join our iOS development team to build next-generation applications for iPhone, iPad, and Apple Watch. You will work on cutting-edge technologies and collaborate with cross-functional teams.',
        daysLeft: 1,
        salary: 160,
        experience: '3+ years',
        workingHours: 'Flexible',
        vacancies: 5,
        skillsRequired: [
          'Swift',
          'iOS SDK',
          'UIKit',
          'Core Data',
          'REST APIs',
          'Git',
          'CI/CD',
        ],
        requirements: [
          'Bachelor\'s degree in Computer Science or related field',
          '3+ years of iOS development experience',
          'Proficient in Swift and Objective-C',
          'Experience with iOS frameworks',
          'Understanding of Apple\'s design principles',
          'Published apps on App Store',
        ],
        benefits: [
          'Health Insurance',
          'Stock Options',
          'Flexible Hours',
          'Remote Work',
          'Device Allowance',
          'Education Reimbursement',
        ],
        companyIndustry: 'Technology',
        companyDescription: 'Apple Inc. is an American multinational technology company that designs, develops, and sells consumer electronics, computer software, and online services.',
        companySize: '154000',
        companyFounded: '1976',
        companyLocation: 'Global',
      ),
      Job(
        id: 3,
        companyName: 'Microsoft',
        companyLogo: 'https://cdn-icons-png.flaticon.com/512/732/732221.png',
        position: 'Cloud Architect',
        location: 'Redmond, WA',
        type: 'Remote',
        description: 'Design and implement cloud solutions using Azure. Must have 5+ years experience in cloud architecture and microservices.',
        daysLeft: 7,
        salary: 200,
        experience: '5+ years',
        workingHours: 'Remote',
        vacancies: 2,
        skillsRequired: [
          'Azure',
          'AWS',
          'Docker',
          'Kubernetes',
          'Microservices',
          'Terraform',
          'CI/CD',
        ],
        requirements: [
          'Bachelor\'s degree in Computer Science or related field',
          '5+ years of cloud architecture experience',
          'Azure certification preferred',
          'Experience with Infrastructure as Code',
          'Knowledge of security best practices',
          'Strong problem-solving skills',
        ],
        benefits: [
          'Health Insurance',
          'Remote Work',
          'Flexible Hours',
          'Bonus',
          'Learning Budget',
          'Wellness Programs',
        ],
        companyIndustry: 'Technology',
        companyDescription: 'Microsoft Corporation is an American multinational technology company which produces computer software, consumer electronics, personal computers, and related services.',
        companySize: '221000',
        companyFounded: '1975',
        companyLocation: 'Global',
      ),
      Job(
        id: 4,
        companyName: 'Amazon',
        companyLogo: 'https://cdn-icons-png.flaticon.com/512/731/731966.png',
        position: 'Data Scientist',
        location: 'Seattle, WA',
        type: 'Full Time',
        description: 'Analyze large datasets and build machine learning models to improve customer experience and optimize business processes.',
        daysLeft: 5,
        salary: 170,
        experience: '4+ years',
        workingHours: '9 AM - 5 PM',
        vacancies: 4,
        skillsRequired: [
          'Python',
          'R',
          'Machine Learning',
          'SQL',
          'TensorFlow',
          'PyTorch',
          'Data Visualization',
        ],
        requirements: [
          'Master\'s or PhD in Computer Science, Statistics, or related field',
          '4+ years of data science experience',
          'Strong statistical analysis skills',
          'Experience with big data technologies',
          'Excellent communication skills',
          'Published research papers preferred',
        ],
        benefits: [
          'Health Insurance',
          'Stock Options',
          'Flexible Hours',
          'Remote Work',
          'Learning Budget',
          'Paid Time Off',
        ],
        companyIndustry: 'E-commerce',
        companyDescription: 'Amazon.com, Inc. is an American multinational technology company focusing on e-commerce, cloud computing, digital streaming, and artificial intelligence.',
        companySize: '1541000',
        companyFounded: '1994',
        companyLocation: 'Global',
      ),
    ]);

    isLoading.value = false;
  }

  // Set selected job index
  void selectJob(int index) {
    selectedJobIndex.value = index;
  }

  // Get currently selected job
  Job get selectedJob {
    if (jobs.isEmpty) {
      // Return a default job if list is empty
      return Job(
        id: 0,
        companyName: 'Loading...',
        companyLogo: 'https://via.placeholder.com/150',
        position: 'Loading...',
        location: 'Loading...',
        type: 'Full Time',
        description: 'Loading...',
        daysLeft: 0,
        salary: 0,
        experience: 'N/A',
        workingHours: 'N/A',
        vacancies: 0,
        skillsRequired: [],
        requirements: [],
        benefits: [],
        companyIndustry: 'N/A',
        companyDescription: 'Loading...',
        companySize: '0',
        companyFounded: 'N/A',
        companyLocation: 'N/A',
      );
    }
    return jobs[selectedJobIndex.value];
  }


  // Apply for job
  void applyForJob() {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Remove loading

      // Show success message
      Get.snackbar(
        'Application Submitted',
        'You have successfully applied for ${selectedJob.position} at ${selectedJob.companyName}',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }

  // Bookmark job
  void toggleBookmark(int jobId) {
    final jobIndex = jobs.indexWhere((job) => job.id == jobId);
    if (jobIndex != -1) {
      jobs[jobIndex] = jobs[jobIndex].copyWith(
        isBookmarked: !jobs[jobIndex].isBookmarked,
      );
      jobs.refresh();

      // Show feedback
      final message = jobs[jobIndex].isBookmarked
          ? 'Job bookmarked'
          : 'Job removed from bookmarks';

      Get.snackbar(
        message,
        '',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

// Job Model
