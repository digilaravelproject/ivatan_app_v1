
class JobsResponseModel {
  final bool status;
  final String message;
  final JobsData data;

  JobsResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory JobsResponseModel.fromJson(Map<String, dynamic> json) {
    return JobsResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: JobsData.fromJson(json['data'] ?? {}),
    );
  }
}


class JobsData {
  final int currentPage;
  final List<JobModel> jobs;
  final int lastPage;
  final int total;
  final String? nextPageUrl;

  JobsData({
    required this.currentPage,
    required this.jobs,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
  });

  factory JobsData.fromJson(Map<String, dynamic> json) {
    return JobsData(
      currentPage: json['current_page'] ?? 0,
      jobs: (json['data'] as List? ?? [])
          .map((e) => JobModel.fromJson(e))
          .toList(),
      lastPage: json['last_page'] ?? 0,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
    );
  }
}


class JobModel {
  final int id;
  final String uuid;
  final int employerId;
  final String title;
  final String slug;
  final String companyName;
  final String? companyWebsite;
  final String? companyLogo;
  final String description;
  final String? responsibilities;
  final String? requirements;
  final String location;
  final String country;
  final String employmentType;
  final String salaryMin;
  final String salaryMax;
  final String currency;
  final bool isRemote;
  final String status;
  final int viewsCount;
  final String createdAt;
  final String updatedAt;
  final EmployerModel employer;

  JobModel({
    required this.id,
    required this.uuid,
    required this.employerId,
    required this.title,
    required this.slug,
    required this.companyName,
    this.companyWebsite,
    this.companyLogo,
    required this.description,
    this.responsibilities,
    this.requirements,
    required this.location,
    required this.country,
    required this.employmentType,
    required this.salaryMin,
    required this.salaryMax,
    required this.currency,
    required this.isRemote,
    required this.status,
    required this.viewsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.employer,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      employerId: json['employer_id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      companyName: json['company_name'] ?? '',
      companyWebsite: json['company_website'],
      companyLogo: json['company_logo'],
      description: json['description'] ?? '',
      responsibilities: json['responsibilities'],
      requirements: json['requirements'],
      location: json['location'] ?? '',
      country: json['country'] ?? '',
      employmentType: json['employment_type'] ?? '',
      salaryMin: json['salary_min'] ?? '',
      salaryMax: json['salary_max'] ?? '',
      currency: json['currency'] ?? '',
      isRemote: json['is_remote'] ?? false,
      status: json['status'] ?? '',
      viewsCount: json['views_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      employer: EmployerModel.fromJson(json['employer'] ?? {}),
    );
  }
}



class EmployerModel {
  final int id;
  final String uuid;
  final String username;
  final String? occupation;
  final String name;
  final String email;
  final String phone;
  final String countryCode;
  final bool isSeller;
  final bool isVerified;
  final bool isEmployer;
  final String status;
  final String? profilePhotoPath;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final EmployerSettings? settings;

  EmployerModel({
    required this.id,
    required this.uuid,
    required this.username,
    this.occupation,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.isSeller,
    required this.isVerified,
    required this.isEmployer,
    required this.status,
    this.profilePhotoPath,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    this.settings,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    return EmployerModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      occupation: json['occupation'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['country_code'] ?? '',
      isSeller: json['is_seller'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isEmployer: json['is_employer'] ?? false,
      status: json['status'] ?? '',
      profilePhotoPath: json['profile_photo_path'],
      bio: json['bio'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      settings: json['settings'] != null
          ? EmployerSettings.fromJson(json['settings'])
          : null,
    );
  }
}


class EmployerSettings {
  final bool darkMode;
  final String language;
  final bool notifications;

  EmployerSettings({
    required this.darkMode,
    required this.language,
    required this.notifications,
  });

  factory EmployerSettings.fromJson(Map<String, dynamic> json) {
    return EmployerSettings(
      darkMode: json['dark_mode'] ?? false,
      language: json['language'] ?? '',
      notifications: json['notifications'] ?? false,
    );
  }
}


class CreateJobRequestModel {
  final String title;
  final String companyName;
  final String? companyWebsite;
  final String description;
  final String employmentType;
  final double salaryMin;
  final double salaryMax;
  final String currency;
  final bool isRemote;
  final String status;
  final String? responsibilities;
  final String? requirements;
  final String? location;
  final String? country;
  final String? companyLogo;

  CreateJobRequestModel({
    required this.title,
    required this.companyName,
    this.companyWebsite,
    required this.description,
    required this.employmentType,
    required this.salaryMin,
    required this.salaryMax,
    required this.currency,
    required this.isRemote,
    required this.status,
    this.responsibilities,
    this.requirements,
    this.location,
    this.country,
    this.companyLogo,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'company_name': companyName,
      'company_website': companyWebsite,
      'description': description,
      'employment_type': employmentType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'currency': currency,
      'is_remote': isRemote,
      'status': status,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'location': location,
      'country': country,
      'company_logo': companyLogo,
    };

    // if (responsibilities != null) data['responsibilities'] = responsibilities;
    // if (requirements != null) data['requirements'] = requirements;
    // if (location != null) data['location'] = location;
    // if (country != null) data['country'] = country;
    // if (companyLogo != null) data['company_logo'] = companyLogo;

    return data;
  }
}
class JobApplicationResponse {
  final bool status;
  final String message;
  final JobApplicationData data;

  JobApplicationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) {
    return JobApplicationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: JobApplicationData.fromJson(json['data'] ?? {}),
    );
  }
}

class JobApplicationData {
  final int currentPage;
  final List<JobApplication> applications;
  final int lastPage;
  final int total;

  JobApplicationData({
    required this.currentPage,
    required this.applications,
    required this.lastPage,
    required this.total,
  });

  factory JobApplicationData.fromJson(Map<String, dynamic> json) {
    return JobApplicationData(
      currentPage: json['current_page'] ?? 0,
      applications: (json['data'] as List? ?? [])
          .map((e) => JobApplication.fromJson(e))
          .toList(),
      lastPage: json['last_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class JobApplication {
  final int id;
  final String uuid;
  final int jobId;
  final int applicantId;
  final String? coverMessage;
  final String? resumePath;
  final String status;
  final String? appliedAt;
  final String createdAt;
  final String updatedAt;
  final ApplicantUserModel applicant;

  JobApplication({
    required this.id,
    required this.uuid,
    required this.jobId,
    required this.applicantId,
    this.coverMessage,
    this.resumePath,
    required this.status,
    this.appliedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.applicant,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      jobId: json['job_id'] ?? 0,
      applicantId: json['applicant_id'] ?? 0,
      coverMessage: json['cover_message'],
      resumePath: json['resume_path'],
      status: json['status'] ?? '',
      appliedAt: json['applied_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      applicant: ApplicantUserModel.fromJson(json['applicant'] ?? {}),
    );
  }

  JobApplication copyWith({
    int? id,
    String? uuid,
    int? jobId,
    int? applicantId,
    String? coverMessage,
    String? resumePath,
    String? status,
    String? appliedAt,
    String? createdAt,
    String? updatedAt,
    ApplicantUserModel? applicant,
  }) {
    return JobApplication(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      coverMessage: coverMessage ?? this.coverMessage,
      resumePath: resumePath ?? this.resumePath,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicant: applicant ?? this.applicant,
    );
  }
}

class ApplicantUserModel {
  final int id;
  final String uuid;
  final String username;
  final String? occupation;
  final String name;
  final String email;
  final String phone;
  final String countryCode;
  final String? profilePhotoPath;
  final String? bio;
  final String status;
  final bool isVerified;
  final String? created_at;

  ApplicantUserModel({
    required this.id,
    required this.uuid,
    required this.username,
    this.occupation,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryCode,
    this.profilePhotoPath,
    this.bio,
    required this.status,
    required this.isVerified,
    this.created_at,
  });

  factory ApplicantUserModel.fromJson(Map<String, dynamic> json) {
    return ApplicantUserModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      occupation: json['occupation'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['country_code'] ?? '',
      profilePhotoPath: json['profile_photo_path'],
      bio: json['bio'],
      status: json['status'] ?? '',
      isVerified: json['is_verified'] ?? false,
      created_at: json['created_at'],
    );
  }
}
