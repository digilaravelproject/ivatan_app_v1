import 'dart:io';

class JobApplicationRequestModel {
  final String? coverMessage;
  final String? resumeHeadline;
  final String? contactNo;
  final List<String>? skillsList;
  final File? resume;
  final List<EmploymentRequestModel>? employments;
  final List<EducationRequestModel>? educations;

  JobApplicationRequestModel({
    this.coverMessage,
    this.resumeHeadline,
    this.contactNo,
    this.skillsList,
    this.resume,
    this.employments,
    this.educations,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (coverMessage != null) data['cover_message'] = coverMessage;
    if (resumeHeadline != null) data['resume_headline'] = resumeHeadline;
    if (contactNo != null) data['contact_no'] = contactNo;
    if (skillsList != null) data['skills_list'] = skillsList;
    if (resume != null) data['resume'] = resume;
    if (employments != null) {
      data['employments'] = employments!.map((v) => v.toJson()).toList();
    }
    if (educations != null) {
      data['educations'] = educations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EmploymentRequestModel {
  final String? companyName;
  final String? jobTitle;
  final bool? isCurrentEmployment;
  final String? joiningDate;
  final String? workedTill;
  final String? jobDescription;

  EmploymentRequestModel({
    this.companyName,
    this.jobTitle,
    this.isCurrentEmployment,
    this.joiningDate,
    this.workedTill,
    this.jobDescription,
  });

  factory EmploymentRequestModel.fromJson(Map<String, dynamic> json) {
    return EmploymentRequestModel(
      companyName: json['company_name'],
      jobTitle: json['job_title'],
      isCurrentEmployment: json['is_current_employment'],
      joiningDate: json['joining_date'],
      workedTill: json['worked_till'],
      jobDescription: json['job_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'job_title': jobTitle,
      'is_current_employment': isCurrentEmployment,
      'joining_date': joiningDate,
      'worked_till': workedTill,
      'job_description': jobDescription,
    };
  }
}

class EducationRequestModel {
  final String? universityName;
  final String? courseName;
  final String? courseType;
  final String? courseDuration;
  final String? percentageCgpa;

  EducationRequestModel({
    this.universityName,
    this.courseName,
    this.courseType,
    this.courseDuration,
    this.percentageCgpa,
  });

  factory EducationRequestModel.fromJson(Map<String, dynamic> json) {
    return EducationRequestModel(
      universityName: json['university_name'],
      courseName: json['course_name'],
      courseType: json['course_type'],
      courseDuration: json['course_duration'],
      percentageCgpa: json['percentage_cgpa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university_name': universityName,
      'course_name': courseName,
      'course_type': courseType,
      'course_duration': courseDuration,
      'percentage_cgpa': percentageCgpa,
    };
  }
}
