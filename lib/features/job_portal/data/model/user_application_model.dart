class UserApplicationsResponse {
  final bool status;
  final String message;
  final UserApplicationsData data;

  UserApplicationsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return UserApplicationsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserApplicationsData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserApplicationsData {
  final int currentPage;
  final List<UserApplication> applications;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  UserApplicationsData({
    required this.currentPage,
    required this.applications,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory UserApplicationsData.fromJson(Map<String, dynamic> json) {
    return UserApplicationsData(
      currentPage: json['current_page'] ?? 0,
      applications: (json['data'] as List? ?? [])
          .map((e) => UserApplication.fromJson(e))
          .toList(),
      lastPage: json['last_page'] ?? 0,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class UserApplication {
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
  final String? resumeUrl;
  final ApplicationJob job;

  UserApplication({
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
    this.resumeUrl,
    required this.job,
  });

  factory UserApplication.fromJson(Map<String, dynamic> json) {
    return UserApplication(
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
      resumeUrl: json['resume_url'],
      job: ApplicationJob.fromJson(json['job'] ?? {}),
    );
  }
}

class ApplicationJob {
  final int id;
  final String uuid;
  final String title;
  final String companyName;
  final int employerId;
  final String slug;
  final ApplicationEmployer employer;

  ApplicationJob({
    required this.id,
    required this.uuid,
    required this.title,
    required this.companyName,
    required this.employerId,
    required this.slug,
    required this.employer,
  });

  factory ApplicationJob.fromJson(Map<String, dynamic> json) {
    return ApplicationJob(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      companyName: json['company_name'] ?? '',
      employerId: json['employer_id'] ?? 0,
      slug: json['slug'] ?? '',
      employer: ApplicationEmployer.fromJson(json['employer'] ?? {}),
    );
  }
}

class ApplicationEmployer {
  final int id;
  final String uuid;
  final String username;
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

  ApplicationEmployer({
    required this.id,
    required this.uuid,
    required this.username,
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
  });

  factory ApplicationEmployer.fromJson(Map<String, dynamic> json) {
    return ApplicationEmployer(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
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
    );
  }
}
