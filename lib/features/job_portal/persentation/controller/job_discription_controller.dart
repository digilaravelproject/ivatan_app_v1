
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/job_model.dart';
import '../../repository/job_repository.dart';
import '../../../../route/app_pages.dart';
import '../controller/job_controller.dart';

class JobDescriptionController extends GetxController {
  final JobRepository repository;
  var job = Rxn<JobModel>();
  var isLoading = false.obs;

  JobDescriptionController(this.repository);

  @override
  void onInit() {
    super.onInit();
    final String? slug = Get.arguments as String?;
    if (slug != null) {
      fetchJobDetails(slug);
    } else {
      // Use post frame callback to avoid showing snackbar during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == AppRoutes.jobDescriptionScreen) {
          Get.back();
          Get.snackbar(
            'Error',
            'No job slug provided',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    }
  }

  // Fetch job details
  Future<void> fetchJobDetails(String slug) async {
    try {
      isLoading.value = true;
      final result = await repository.getJobDetails(slug);
      job.value = result;
    } catch (e) {
      print('Error fetching job details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void editJob() {
    if (job.value != null) {
      final jobController = Get.find<JobController>();
      jobController.setEditingJob(job.value!);
      Get.toNamed(AppRoutes.jobCreateScreen);
    }
  }

  Future<void> deleteJob() async {
    if (job.value != null) {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Job'),
          content: const Text('Are you sure you want to delete this job?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back(); // Close dialog
                final success = await repository.deleteJob(job.value!.id);
                if (success) {
                  Get.back(); // Go back to list
                  Get.snackbar(
                    'Success',
                    'Job deleted successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  Get.find<JobController>().fetchJobs();
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to delete job.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  // Apply for job
  void applyForJob() {
    if (job.value == null) return;

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
        'You have successfully applied for ${job.value!.title} at ${job.value!.companyName}',
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }

  // Bookmark job
  final RxBool isBookmarked = false.obs;
  
  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    
    final message = isBookmarked.value
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
