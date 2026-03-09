import 'job_application_request_model.dart';

class CareerProfileModel {
  final int id;
  final int userId;
  final String? resumeHeadline;
  final List<String> skillsList;
  final String? contactNo;
  final List<EmploymentRequestModel> employments;
  final List<EducationRequestModel> educations;

  CareerProfileModel({
    required this.id,
    required this.userId,
    this.resumeHeadline,
    required this.skillsList,
    this.contactNo,
    required this.employments,
    required this.educations,
  });

  factory CareerProfileModel.fromJson(Map<String, dynamic> json) {
    return CareerProfileModel(
      id: json['id'],
      userId: json['user_id'],
      resumeHeadline: json['resume_headline'],
      skillsList: List<String>.from(json['skills_list'] ?? []),
      contactNo: json['contact_no'],
      employments: (json['employments'] as List?)
              ?.map((e) => EmploymentRequestModel.fromJson(e))
              .toList() ??
          [],
      educations: (json['educations'] as List?)
              ?.map((e) => EducationRequestModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
