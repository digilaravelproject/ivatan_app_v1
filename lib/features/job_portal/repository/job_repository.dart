import 'package:http/http.dart' as http;
import 'dart:io';
import '../data/model/career_profile_model.dart';
import '../data/model/job_model.dart';
import '../data/model/user_application_model.dart';
import '../data/model/job_application_request_model.dart';
import '../data_source/job_data_source.dart';

abstract class JobRepository {
  Future<List<JobModel>> getJobs({
    String? q,
    String? location,
    String? country,
    String? employmentType,
    bool? isRemote,
    double? salaryMin,
    double? salaryMax,
    int page = 1,
  });
  Future<JobModel?> getJobDetails(String slug);
  Future<String?> createJob(CreateJobRequestModel request, {File? logoFile});
  Future<String?> updateJob(int id, CreateJobRequestModel request, {File? logoFile});
  Future<bool> deleteJob(int id);
  Future<List<JobApplication>> getJobApplications(int jobId);
  Future<List<UserApplication>> getUserApplications({String? status});
  Future<String?> applyJob(int jobId, JobApplicationRequestModel request); // Added applyJob method
  Future<http.Response?> downloadResume(int applicationId);
  Future<bool> updateApplicationStatus(int id, String status);
  Future<Map<String, dynamic>> getRecruiterJobs({int page = 1, String? search});
  Future<CareerProfileModel?> getCareerProfile();
}




class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JobModel>> getJobs({
    String? q,
    String? location,
    String? country,
    String? employmentType,
    bool? isRemote,
    double? salaryMin,
    double? salaryMax,
    int page = 1,
  }) {
    return remoteDataSource.getJobs(
      q: q,
      location: location,
      country: country,
      employmentType: employmentType,
      isRemote: isRemote,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      page: page,
    );
  }

  @override
  Future<String?> createJob(CreateJobRequestModel request, {File? logoFile}) {
    return remoteDataSource.createJob(request, logoFile: logoFile);
  }

  @override
  Future<String?> updateJob(int id, CreateJobRequestModel request, {File? logoFile}) {
    return remoteDataSource.updateJob(id, request, logoFile: logoFile);
  }

  @override
  Future<bool> deleteJob(int id) {
    return remoteDataSource.deleteJob(id);
  }
  @override
  Future<List<JobApplication>> getJobApplications(int jobId) {
    return remoteDataSource.getJobApplications(jobId);
  }

  @override
  Future<List<UserApplication>> getUserApplications({String? status}) {
    return remoteDataSource.getUserApplications(status: status);
  }

  @override
  Future<JobModel?> getJobDetails(String slug) {
    return remoteDataSource.getJobDetails(slug);
  }
  @override
  Future<http.Response?> downloadResume(int applicationId) {
    return remoteDataSource.downloadResume(applicationId);
  }

  @override
  Future<bool> updateApplicationStatus(int id, String status) {
    return remoteDataSource.updateApplicationStatus(id, status);
  }

  Future<String?> applyJob(int jobId, JobApplicationRequestModel request) {
    return remoteDataSource.applyJob(jobId, request);
  }

  @override
  Future<Map<String, dynamic>> getRecruiterJobs({int page = 1, String? search}) {
    return remoteDataSource.getRecruiterJobs(page: page, search: search);
  }

  @override
  Future<CareerProfileModel?> getCareerProfile() {
    return remoteDataSource.getCareerProfile();
  }
}
