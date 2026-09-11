import 'package:get/get.dart';

import '../../../../core/network/api_services.dart';
import '../../../../core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';
import '../model/req/login_req_model.dart';
import '../model/req/register_req_model.dart';
import '../model/res/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> makeUserLogin(LoginReqModel req);

  Future<UserModel> UserLoginWithPassword(LoginReqModel req);

  Future<UserModel> makeUserRegister(RegisterReqModel req);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> makeUserLogin(LoginReqModel req) async {
    final response = await Get.find<ApiServices>().callPost(
     // AppUrls.login,
      AppUrls.loginOtp,

      //data: req.toPasswordMap(),
      data: req.toMap(),
      isFormData: true,
      showErrorToast: false, // LoginController will handle errors
    );
    if (response == null) {
      throw Exception("Invalid Credentials");
    }

    if (response['status'] == false) {
      throw Exception(response['message'] ?? "Invalid Credentials");
    }

    if (response['data'] == null) {
      throw Exception(response['message'] ?? "Login failed");
    }

    final userModel = UserModel.fromJson(response['data']);
    final pref = SharedPrefManager();
    await pref.saveUserData(userModel.toJson());
    return userModel;
  }

  Future<UserModel> UserLoginWithPassword(LoginReqModel req) async {
    final response = await Get.find<ApiServices>().callPost(
       AppUrls.login,
    //  AppUrls.loginOtp,

      data: req.toPasswordMap(),
     // data: req.toMap(),
      isFormData: false,
    );
    if (response == null) {
      throw Exception("Invalid Credentials");
    }

    if (response['status'] == false) {
      throw Exception(response['message'] ?? "Invalid Credentials");
    }

    final userModel = UserModel.fromJson(response['data']);
    final pref = SharedPrefManager();
    await pref.saveUserData(userModel.toJson());
    return userModel;
  }

  @override
  Future<UserModel> makeUserRegister(RegisterReqModel req) async {
    final response = await Get.find<ApiServices>().callPost(
      AppUrls.register,
      data: req.toMap(),
    );

    print("registrationResponse: $response");

    if (response == null) {
      throw Exception("Server did not respond");
    }

    if (response["errors"] != null && response["errors"] is Map) {
      final errorsMap = response["errors"] as Map;
      if (errorsMap.isNotEmpty) {
        final firstErrorList = errorsMap.values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          throw Exception(firstErrorList.first.toString());
        }
      }
    }

    if (response["data"] == null || response["data"] is! Map) {
      if (response["message"] != null) {
        throw Exception(response["message"]);
      }
      throw Exception("Registration failed");
    }

    // Save user session
    final userModel = UserModel.fromJson(response['data']);
    final pref = SharedPrefManager();
    if (req.profileType != null && req.profileType!.isNotEmpty) {
      await pref.setRegisteredProfileType(req.profileType);
      await pref.setActiveProfileType(req.profileType);
      if (req.profileSubType != null && req.profileSubType!.isNotEmpty) {
        await pref.setRegisteredProfileSubType(req.profileSubType);
      }
    }
    await pref.saveUserData(userModel.toJson());
    
    return userModel;
  }
}
