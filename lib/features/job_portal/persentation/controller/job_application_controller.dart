import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/helper/custom_snack_bar.dart';
import '../../data/model/career_profile_model.dart';
import '../../data/model/job_application_request_model.dart';
import '../../repository/job_repository.dart';

class JobApplicationController extends GetxController {
  final JobRepository repository;
  final int jobId;

  JobApplicationController({required this.repository, required this.jobId});

  @override
  void onInit() {
    super.onInit();
    fetchCareerProfile();
  }

  // Basic Info
  final resumeHeadlineController = TextEditingController();
  final coverMessageController = TextEditingController();
  final phoneController = TextEditingController();
  
  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Education
  final universityController = TextEditingController();
  final courseController = TextEditingController();
  final durationController = TextEditingController();
  final gradeController = TextEditingController();
  final RxString courseType = 'full_time'.obs;
  final RxList<EducationRequestModel> educationList = <EducationRequestModel>[].obs;

  // Employment
  final companyNameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final jobDescriptionController = TextEditingController();
  final Rxn<DateTime> joiningDate = Rxn<DateTime>();
  final Rxn<DateTime> workedTillDate = Rxn<DateTime>();
  final RxBool isCurrentEmployment = false.obs;
  final RxList<EmploymentRequestModel> employmentList = <EmploymentRequestModel>[].obs;

  // Skills
  final skillController = TextEditingController();
  final RxList<String> selectedSkills = <String>[].obs;

  // UI State
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProfileLoading = false.obs;

  Future<void> fetchCareerProfile() async {
    isProfileLoading.value = true;
    try {
      final profile = await repository.getCareerProfile();
      if (profile != null) {
        // Basic Info
        resumeHeadlineController.text = _stripQuotes(profile.resumeHeadline ?? '');
        phoneController.text = _stripQuotes(profile.contactNo ?? '');
        
        // Education
        educationList.assignAll(profile.educations);
        
        // Employment
        employmentList.assignAll(profile.employments);
        
        // Skills
        selectedSkills.assignAll(profile.skillsList.map((s) => _stripQuotes(s)));
      }
    } catch (e) {
      debugPrint('Error fetching career profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  String _stripQuotes(String value) {
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  Future<void> pickFile() async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        // Simulate progress
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 50));
          uploadProgress.value = i / 100;
        }
        selectedFile.value = result.files.first;
      }
    } catch (e) {
      CustomSnackBar.showError(message: 'Error picking file: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void addEducation() {
    if (universityController.text.isEmpty || courseController.text.isEmpty) {
      CustomSnackBar.showError(message: 'Please fill university and course');
      return;
    }

    educationList.add(EducationRequestModel(
      universityName: universityController.text,
      courseName: courseController.text,
      courseType: courseType.value,
      courseDuration: durationController.text,
      percentageCgpa: gradeController.text,
    ));

    universityController.clear();
    courseController.clear();
    durationController.clear();
    gradeController.clear();
  }

  void removeEducation(int index) {
    educationList.removeAt(index);
  }

  void addEmployment() {
    if (companyNameController.text.isEmpty || jobTitleController.text.isEmpty) {
      CustomSnackBar.showError(message: 'Please fill company and job title');
      return;
    }

    employmentList.add(EmploymentRequestModel(
      companyName: companyNameController.text,
      jobTitle: jobTitleController.text,
      jobDescription: jobDescriptionController.text,
      isCurrentEmployment: isCurrentEmployment.value,
      joiningDate: joiningDate.value?.toIso8601String(),
      workedTill: workedTillDate.value?.toIso8601String(),
    ));

    companyNameController.clear();
    jobTitleController.clear();
    jobDescriptionController.clear();
    joiningDate.value = null;
    workedTillDate.value = null;
    isCurrentEmployment.value = false;
  }

  void removeEmployment(int index) {
    employmentList.removeAt(index);
  }

  void addSkill() {
    final skill = skillController.text.trim();
    if (skill.isNotEmpty && !selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
      skillController.clear();
    }
  }

  void removeSkill(String skill) {
    selectedSkills.remove(skill);
  }

  Future<void> submitApplication() async {
    if (selectedFile.value == null) {
      CustomSnackBar.showError(message: 'Please upload your resume');
      currentStep.value = 0;
      return;
    }

    if (resumeHeadlineController.text.isEmpty) {
      CustomSnackBar.showError(message: 'Please enter resume headline');
      currentStep.value = 0;
      return;
    }

    isLoading.value = true;
    try {
      final request = JobApplicationRequestModel(
        coverMessage: coverMessageController.text,
        resumeHeadline: resumeHeadlineController.text,
        contactNo: phoneController.text,
        skillsList: selectedSkills,
        resume: File(selectedFile.value!.path!),
        educations: educationList,
        employments: employmentList,
      );

      final message = await repository.applyJob(jobId, request);
      if (message != null) {
        Get.back();
        CustomSnackBar.showSuccess(message: message);
      }
    } catch (e) {
      CustomSnackBar.showError(message: e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    resumeHeadlineController.dispose();
    coverMessageController.dispose();
    phoneController.dispose();
    universityController.dispose();
    courseController.dispose();
    durationController.dispose();
    gradeController.dispose();
    companyNameController.dispose();
    jobTitleController.dispose();
    jobDescriptionController.dispose();
    skillController.dispose();
    super.onClose();
  }
}
