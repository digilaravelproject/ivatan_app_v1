import 'package:http/http.dart' as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'dart:io';

import '../../../core/network/api_services.dart';
import '../data/model/career_profile_model.dart';
import '../data/model/job_model.dart';
import '../data/model/user_application_model.dart';
import '../data/model/job_application_request_model.dart';

abstract class JobRemoteDataSource {
  Future<List<JobModel>> getJobs({
    String? q,
    int page = 1,
  });

  Future<JobModel?> getJobDetails(String slug);

  Future<String?> createJob(CreateJobRequestModel request, {File? logoFile});

  Future<String?> updateJob(int id, CreateJobRequestModel request,
      {File? logoFile});

  Future<bool> deleteJob(int id);

  Future<List<JobApplication>> getJobApplications(int jobId);

  Future<List<UserApplication>> getUserApplications({String? status});

  Future<http.Response?> downloadResume(int applicationId);

  Future<bool> updateApplicationStatus(int id, String status);

  Future<String?> applyJob(int jobId, JobApplicationRequestModel request);

  Future<Map<String, dynamic>> getRecruiterJobs({int page = 1, String? search});
  Future<CareerProfileModel?> getCareerProfile();
}


class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiServices apiServices = Get.find<ApiServices>();

  @override
  Future<List<JobModel>> getJobs({
    String? q,
    int page = 1,
  }) async {
    Map<String, String> queryParams = {'page': page.toString()};

    if (q != null && q.isNotEmpty) queryParams['q'] = q;

    final response = await apiServices.callGet(AppUrls.allJobs, queryParams: queryParams);

    print("alljobs : "+response.toString());

    if (response != null && response['status'] == true) {
      final List dataList = response['data']['data'];
      return dataList.map((e) => JobModel.fromJson(e)).toList();
    }

    return [];
  }

  @override
  Future<String?> createJob(CreateJobRequestModel request, {File? logoFile}) async {
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

    if (response != null) {
      if (response['status'] == true) {
        return response['message']?.toString() ?? 'Job created successfully.';
      } else {
        String errorMessage = response['message']?.toString() ?? 'Failed to create job.';
        if (response['errors'] != null && response['errors'] is Map) {
          final errors = response['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        }
        throw errorMessage;
      }
    }
    return null;
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
  Future<String?> updateJob(int id, CreateJobRequestModel request, {File? logoFile}) async {
    final data = request.toJson();
    data['_method'] = 'PUT'; // Laravel method spoofing for handling multipart form data correctly
    
    // Add logo file if provided
    if (logoFile != null) {
      data['company_logo'] = logoFile;
    }

    final response = await apiServices.callPost(
      "${AppUrls.allJobs}/$id",
      data: data,
      isFormData: true, // Always use form data so method spoofing and files work robustly
    );

    if (response != null) {
      if (response['status'] == true) {
        return response['message']?.toString() ?? 'Job updated successfully.';
      } else {
        String errorMessage = response['message']?.toString() ?? 'Failed to update job.';
        if (response['errors'] != null && response['errors'] is Map) {
          final errors = response['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        }
        throw errorMessage;
      }
    }
    return null;
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

  @override
  Future<String?> applyJob(int jobId, JobApplicationRequestModel request) async {
    final data = request.toJson();
    
    final response = await apiServices.callPost(
      "api/v1/jobs/$jobId/apply",
      data: data,
      isFormData: true,
      showErrorToast: false,
    );

    if (response != null) {
      if (response['status'] == true || response['success'] == true) {
        return response['message']?.toString() ?? 'Application submitted successfully';
      } else {
        String errorMessage = response['message']?.toString() ?? 'Failed to apply for job.';
        if (response['errors'] != null && response['errors'] is Map) {
          final errors = response['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        }
        throw errorMessage;
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> getRecruiterJobs({int page = 1, String? search}) async {
    String url = "${AppUrls.recruiterJobs}?page=$page";
    if (search != null && search.isNotEmpty) {
      url += "&search=$search&title=$search";
    }

    final response = await apiServices.callGet(url, showErrorToast: false);

    if (response != null && response['status'] == true) {
      final List dataList = response['data']['data'];
      final List<JobModel> jobs = dataList.map((e) => JobModel.fromJson(e)).toList();
      
      return {
        'jobs': jobs,
        'current_page': response['data']['current_page'],
        'last_page': response['data']['last_page'],
        'total': response['data']['total'],
      };
    }

    return {
      'jobs': <JobModel>[],
      'current_page': page,
      'last_page': page,
      'total': 0,
    };
  }

  @override
  Future<CareerProfileModel?> getCareerProfile() async {
    final response = await apiServices.callGet(AppUrls.careerProfile);

    if (response != null && response['status'] == true) {
      return CareerProfileModel.fromJson(response['data']);
    }

    return null;
  }
}
