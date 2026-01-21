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
      isFormData: true,
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

    if (response["data"] == null || response["data"] is! Map) {
      if (response["message"] != null) {
        throw Exception(response["message"]);
      }
      throw Exception("Registration failed");
    }

    // Save user session
    final userModel = UserModel.fromJson(response['data']);
    final pref = SharedPrefManager();
    await pref.saveUserData(userModel.toJson());
    
    return userModel;
  }
}
