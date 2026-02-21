import 'package:get/get.dart';
import '../../data/model/job_model.dart';
import '../../repository/job_repository.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/helper/custom_snack_bar.dart';

class ApplicantController extends GetxController {
  final JobRepository repository;

  ApplicantController(this.repository);

  var applicants = <JobApplication>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Job ID should be passed when navigating to the list
    if (Get.arguments is int) {
      fetchApplicants(Get.arguments as int);
    }
  }

  Future<void> fetchApplicants(int jobId) async {
    try {
      isLoading.value = true;
      final result = await repository.getJobApplications(jobId);
      applicants.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch applicants: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  JobApplication? getApplicantById(int id) {
    return applicants.firstWhereOrNull((a) => a.id == id);
  }

  Future<void> downloadResume(int applicationId, String? fileName) async {
    try {
      isLoading.value = true;
      final response = await repository.downloadResume(applicationId);

      if (response != null && response.bodyBytes.isNotEmpty) {
        final directory = await getTemporaryDirectory();
        final name = fileName ?? "resume_$applicationId.pdf";
        final filePath = "${directory.path}/$name";
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
            [XFile(filePath)], text: 'Applicant Resume: $name');

        CustomSnackBar.showSuccess(message: "Resume downloaded successfully");
      } else {
        CustomSnackBar.showError(message: "Failed to download resume");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Error downloading resume: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int applicationId, String status) async {
    try {
      isLoading.value = true;
      final success = await repository.updateApplicationStatus(
          applicationId, status);

      print("updateStatus : "+status);
      if (success) {
        // Update local state reactively
        final index = applicants.indexWhere((element) =>
        element.id == applicationId);
        if (index != -1) {
          final updatedApplicant = applicants[index].copyWith(status: status);
          applicants[index] = updatedApplicant;
          applicants.refresh();
        }
        CustomSnackBar.showSuccess(
            message: "Status updated to $status successfully");
      } else {
        CustomSnackBar.showError(message: "Failed to update status");
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Error updating status: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
