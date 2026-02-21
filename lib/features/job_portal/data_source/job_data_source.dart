import 'package:http/http.dart' as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'dart:io';

import '../../../core/network/api_services.dart';
import '../data/model/job_model.dart';
import '../data/model/user_application_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs();

  Future<JobModel?> getJobDetails(String slug);

  Future<bool> createJob(CreateJobRequestModel request, {File? logoFile});

  Future<bool> updateJob(int id, CreateJobRequestModel request,
      {File? logoFile});

  Future<bool> deleteJob(int id);

  Future<List<JobApplication>> getJobApplications(int jobId);

  Future<List<UserApplication>> getUserApplications({String? status});

  Future<http.Response?> downloadResume(int applicationId);

  Future<bool> updateApplicationStatus(int id, String status);
}


class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<List<JobModel>> getJobs() async {
    final response = await apiServices.callGet(AppUrls.allJobs);

    if (response != null && response['status'] == true) {
      final List dataList = response['data']['data'];
      return dataList.map((e) => JobModel.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<bool> createJob(CreateJobRequestModel request, {File? logoFile}) async {
    final data = request.toJson();
    
    // Add logo file if provided
    if (logoFile != null) {
      data['company_logo'] = logoFile;
    }

    final response = await apiServices.callPost(
      AppUrls.allJobs,
      data: data,
      isFormData: logoFile != null,
    );

    return response != null && response['status'] == true;
  }

  @override
  Future<JobModel?> getJobDetails(String slug) async {
    final response = await apiServices.callGet("${AppUrls.allJobs}/$slug");

    if (response != null && response['status'] == true) {
      return JobModel.fromJson(response['data']);
    }

    return null;
  }

  @override
  Future<bool> updateJob(int id, CreateJobRequestModel request, {File? logoFile}) async {
    final data = request.toJson();
    
    // Add logo file if provided
    if (logoFile != null) {
      data['company_logo'] = logoFile;
    }

    final response = await apiServices.callPut(
      "${AppUrls.allJobs}/$id",
      data: data,
      isFormData: logoFile != null,
    );

    return response != null && response['status'] == true;
  }

  @override
  Future<bool> deleteJob(int id) async {
    final response = await apiServices.callDelete("${AppUrls.allJobs}/$id");

    return response != null && response['status'] == true;
  }
  @override
  Future<List<JobApplication>> getJobApplications(int jobId) async {
    final response = await apiServices.callGet("${AppUrls.allJobs}/$jobId/applications");

    if (response != null && response['status'] == true) {
      final List dataList = response['data']['data'];
      return dataList.map((e) => JobApplication.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<List<UserApplication>> getUserApplications({String? status}) async {
    String endpoint = "api/v1/jobs/my/applications";
    if (status != null && status != 'all') {
      endpoint += "?status=$status";
    }

    final response = await apiServices.callGet(endpoint);

    if (response != null && response['status'] == true) {
      final userAppResponse = UserApplicationsResponse.fromJson(response);
      return userAppResponse.data.applications;
    }

    return [];
  }

  Future<http.Response?> downloadResume(int applicationId) async {
    return await apiServices.callDownload("api/v1/jobs/applications/$applicationId/resume");
  }

  @override
  Future<bool> updateApplicationStatus(int id, String status) async {
    final response = await apiServices.callPost(
      "api/v1/jobs/applications/$id/status",
      data: {"status": status},
      isFormData: true,
    );

    return response != null && response['status'] == true;
  }
}
