import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobProfileController extends GetxController {

  // Resume
  var resumeFileName = "".obs;
  TextEditingController headlineController = TextEditingController();
  TextEditingController coverLetterController = TextEditingController();

  // Education List
  var educationList = <Map<String, dynamic>>[].obs;

  // Employment List
  var employmentList = <Map<String, dynamic>>[].obs;

  // Skills
  var selectedSkills = <String>[].obs;
  var allSkills = [
    "Flutter",
    "Dart",
    "Java",
    "Kotlin",
    "Firebase",
    "API Integration"
  ].obs;

  void addEducation(Map<String, dynamic> data) {
    educationList.add(data);
  }

  void addEmployment(Map<String, dynamic> data) {
    employmentList.add(data);
  }

  void addSkill(String skill) {
    if (!allSkills.contains(skill)) {
      allSkills.add(skill);
    }
    selectedSkills.add(skill);
  }

}
