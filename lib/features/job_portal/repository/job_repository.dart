import 'package:http/http.dart' as http;
import 'dart:io';
import '../data/model/job_model.dart';
import '../data/model/user_application_model.dart';
import '../data_source/job_data_source.dart';

abstract class JobRepository {
  Future<List<JobModel>> getJobs();
  Future<JobModel?> getJobDetails(String slug);
  Future<bool> createJob(CreateJobRequestModel request, {File? logoFile});
  Future<bool> updateJob(int id, CreateJobRequestModel request, {File? logoFile});
  Future<bool> deleteJob(int id);
  Future<List<JobApplication>> getJobApplications(int jobId);
  Future<List<UserApplication>> getUserApplications({String? status});
  Future<http.Response?> downloadResume(int applicationId);
  Future<bool> updateApplicationStatus(int id, String status);
}





class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JobModel>> getJobs() {
    return remoteDataSource.getJobs();
  }

  @override
  Future<bool> createJob(CreateJobRequestModel request, {File? logoFile}) {
    return remoteDataSource.createJob(request, logoFile: logoFile);
  }

  @override
  Future<bool> updateJob(int id, CreateJobRequestModel request, {File? logoFile}) {
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
}
