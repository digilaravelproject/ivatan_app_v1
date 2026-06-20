import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';

import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/helper/logger_helper.dart';
import '../../../core/network/api_services.dart';
import '../../../core/theme/custom_loader.dart';
import '../../../db/auth_service.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../data/data_source/auth_remote_data_source.dart';
import '../data/model/req/login_req_model.dart';
import '../persentation/verifyOtp.dart';
import 'intrest_controller.dart';
import '../persentation/interest_screen.dart';
import '../controller/register_controller.dart';
import 'package:i_vatan_app/features/Notification/controller/notification_controller.dart';

class LoginController extends GetxController {
  final AuthRemoteDataSource authDataSource;

  LoginController({required this.authDataSource});

  @override
  void onInit() {
    super.onInit();
    // ⚡️ Pre-fetch Interests API in background so Register screen loads instantly
    // "login se register page pe jane pe loading show ho rhi hai wo phele hi load ho jaye"
    Get.put(InterestController()); 
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<OtpFlowType> otpFlowType = OtpFlowType.login.obs;
  var isLoginPass = true.obs;
  var isShowPassword = true.obs;
  
  var resetToken;


  var countryCode = "+91".obs;
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassworController = TextEditingController();
  
  var mobilePhone ;


  final AuthService _authService = AuthService();

  var isGoogleLoading = false.obs;
  late final user = _authService.currentUser;
  RxBool isLoading = false.obs;

  final ApiServices api = ApiServices();

  /// Form Key
  final formKey = GlobalKey<FormState>();

  /// Observables
  var selectRememberPassword = false.obs;
  var isPasswordVisible = false.obs;
  var isCallingApi = false.obs;
  var isRemember = false.obs;

  /// VALIDATORS
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null) {
      return "Phone number is required";
    }
    if (value.trim().isEmpty) {
      return "Phone number is required";
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return "Enter a valid 10-digit phone number";
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Minimum 8 characters required";
    }
    if (!RegExp(r'.*[A-Za-z].*').hasMatch(value)) {
      return "Password must contain at least 1 alphabet";
    }
    if (!RegExp(r'.*\d.*').hasMatch(value)) {
      return "Password must contain at least 1 number";
    }
    if (!RegExp(r'.*[!@#\$%^&*(),.?\":{}|<>].*').hasMatch(value)) {
      return "Password must contain at least 1 special character";
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Please confirm password";
    if (value != passwordController.text.trim()) {
      return "Passwords do not match";
    }
    if (value.length < 8) {
      return "Minimum 8 characters required";
    }
    if (!RegExp(r'.*[A-Za-z].*').hasMatch(value)) {
      return "Password must contain at least 1 alphabet";
    }
    if (!RegExp(r'.*\d.*').hasMatch(value)) {
      return "Password must contain at least 1 number";
    }
    if (!RegExp(r'.*[!@#\$%^&*(),.?\":{}|<>].*').hasMatch(value)) {
      return "Password must contain at least 1 special character";
    }
    return null;
  }
  
  Future<void> callPasswordLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    try {
      isCallingApi.value = true;
      CustomLoader.show();

      final modal = await authDataSource.UserLoginWithPassword(
        LoginReqModel(
          phone: mobileController.text,
          password: passwordController.text,
        ),
      );

      printMessage("callLoginAPI : " + modal.name);
      final msg =
          "Congratulations ${modal.name}, you have successfully logged in!";

      try {
        Get.find<NotificationController>().initNotification();
      } catch (e) {
        print("Notification init error on password login: $e");
      }

      Get.offAllNamed(AppRoutes.navigationScreen);

      CustomSnackBar.showSuccess(message: msg);
    } catch (e, stk) {
      printMessage("Exception : " + e.toString() + "\n$stk");
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isCallingApi.value = false;
      CustomLoader.hide();
    }
  }
  /// API CALL
  Future<void> callLoginAPI(String phone, String firebaseToken) async {
    try {
      isCallingApi.value = true;
      CustomLoader.show();

      final modal = await authDataSource.makeUserLogin(
        LoginReqModel(phone: phone, firebaseToken: firebaseToken),
      );
      print("firebaseToken : "+firebaseToken.toString());
      printMessage("callLoginAPI : " + modal.name);
      final msg = "Congratulations ${modal.name}, you have successfully logged in!";

      try {
        Get.find<NotificationController>().initNotification();
      } catch (e) {
        print("Notification init error on OTP login: $e");
      }

      Get.offAllNamed(AppRoutes.navigationScreen);

      CustomSnackBar.showSuccess(message: msg);
    } catch (e, stk) {
      String errorMsg = e.toString();
      printMessage("Exception : " + errorMsg + "\n$stk");
      CustomLoader.hide(); // Hide loader before redirecting

      if (errorMsg.contains("Mobile number not registered")) {
        // Redirecting silently to Registration...
        
        // Inject RegisterController and pre-fill phone
        if (!Get.isRegistered<RegisterController>()) {
          Get.put(RegisterController(dataSource: authDataSource));
        }
        final registerController = Get.find<RegisterController>();
        registerController.phoneController.text = phone;
        registerController.countryCode.value = countryCode.value;
        
        // Navigate to Interest Screen (Step 1)
        Get.to(() => const InterestScreen());
      } else {
        CustomSnackBar.showError(message: errorMsg);
      }
    } finally {
      isCallingApi.value = false;
      // CustomLoader.hide(); // Handled above for specific cases
    }
  }

  Future<void> sendOTP({required OtpFlowType flowType}) async {
    print("sendotp : click here");

    String phone = mobileController.text.trim();

    if (phone.isEmpty) {
      CustomSnackBar.showError(message: 'Please enter mobile number');
      return;
    }
    if (phone.length != 10) {
      CustomSnackBar.showError(message: 'Please enter valid phone number');
      return;
    }

    otpFlowType.value = flowType;
    isLoading.value = true;
    String phoneNumber = '${countryCode.value}$phone';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            String? firebaseToken = await userCredential.user?.getIdToken();
            
            if (firebaseToken != null) {
              await _handleOtpSuccess(firebaseToken);
            }
          } catch (e) {
            CustomSnackBar.showError(message: "Auto-verification failed: $e");
          } finally {
            isLoading.value = false;
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          CustomSnackBar.showError(message: e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          print('OTP sent. VerificationId: $verificationId');
          Get.to(
            () => VerifyOtp(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Ensure loading stops if code isn't sent/received in time
          if (isLoading.value) {
             isLoading.value = false;
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.showError(message: "Failed to send OTP. Please try again.");
      print("sendOTP Error: $e");
    }
  }

  /// Verify OTP entered by user
  Future<void> verifyOTP(String verificationId, String otp) async {
    try {
      isLoading.value = true;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      String? firebaseToken = await userCredential.user?.getIdToken();
      print("🔥 Firebase Token: $firebaseToken");
      print("📱 Mobile: ${mobileController.text.trim()}");
      
      if (firebaseToken != null) {
        await _handleOtpSuccess(firebaseToken);
      } else {
        throw Exception("Failed to retrieve token");
      }
    } catch (e) {
      print("verifyOTP Error: $e");
      String errorMessage = "Invalid OTP. Please try again.";
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      CustomSnackBar.showError(message: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _handleOtpSuccess(String firebaseToken) async {
    final phone = mobileController.text.trim();

    if (otpFlowType.value == OtpFlowType.login) {
      // ✅ LOGIN FLOW
      await callLoginAPI(phone, firebaseToken);
    } else if (otpFlowType.value == OtpFlowType.forgetPassword) {
      // ✅ FORGET PASSWORD FLOW
      await verifyForgetPassword(phone, firebaseToken);
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> googleLogin() async {
    try {
      print("🔵 googleLogin Step 1: Starting Google Sign In...");
      isGoogleLoading.value = true;
      CustomLoader.show();

      print(
        "🔵 googleLogin Step 2: Calling _authService.signInWithGoogle()...",
      );
      final userCredential = await _authService.signInWithGoogle();

      print(
        "🔵 googleLogin Step 3: UserCredential received: ${userCredential != null}",
      );

      if (userCredential == null) {
        print("🔴 googleLogin Google Sign In cancelled or failed");
        CustomSnackBar.showError(message: "Google Sign In cancelled");
        return;
      }

      final user = userCredential.user;

      if (user == null) {
        print("🔴 googleLogin  User is null after sign in");
        CustomSnackBar.showError(message: "User data not found");
        return;
      }

      print(
        "🔵 googleLogin Step 4: User data - Email: ${user.email}, UID: ${user.uid}",
      );

      print("🔵 googleLogin Step 5: Calling backend API...");
      final response = await api.callPost(
        "api/auth/google-login",
        data: {"google_id": user.uid, "email": user.email},
      );

      print("🔵 googleLogin Step 6: Backend Response: $response");

      if (response == null) {
        return;
      }

      if (response['status'] == true && response['data'] != null) {
        final pref = SharedPrefManager();
        await pref.saveUserData(response['data']);
        try {
          Get.find<NotificationController>().initNotification();
        } catch (e) {
          print("Notification init error on Google login: $e");
        }
        Get.offAllNamed(AppRoutes.navigationScreen);

        final msg = "Welcome ${user.displayName ?? 'User'}!";
        CustomSnackBar.showSuccess(message: msg);
      } else {
        CustomSnackBar.showError(
          message: response['message'] ?? "Server Login Failed",
        );
      }
    } catch (e, stackTrace) {
      print("🔴 Google Login Error: $e");
      print("🔴 Stack Trace: $stackTrace");
      CustomSnackBar.showError(message: "Login failed: ${e.toString()}");
    } finally {
      isGoogleLoading.value = false;
      CustomLoader.hide();
    }
  }

  /// For Forget Password

  Future<void> verifyForgetPassword(String phone, String firebaseToken) async {
    try {
      isCallingApi.value = true;
      CustomLoader.show();
      mobilePhone = phone;
      final response = await api.callPost(
        AppUrls.verifyForgetPassword,
        data: {
          "mobile": phone,
          "firebase_uid": firebaseToken
        },
      );

      if (response != null && response["status"] !=false) {
      String msg = response["message"].toString();
      resetToken = response["reset_token"];
      print("verifyForgetPassword : "+response.toString());
      CustomSnackBar.showSuccess(message: msg);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.NewPasswordPage);
      }


    } catch (e, stk) {
      printMessage("Exception : " + e.toString() + "\n$stk");
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isCallingApi.value = false;
      CustomLoader.hide();
    }
  }

  Future<void> resetPassword() async {
    try {
      isCallingApi.value = true;
      CustomLoader.show();
      print("resetPassword : mobilePhone "+mobilePhone+" resetToken : "+resetToken+" new_password : "+passwordController.text+" confirmPassworController : "+confirmPassworController.text);

      final response = await api.callPost(
        AppUrls.changePassword,
        data: {
          "mobile": mobilePhone,
          "reset_token": resetToken,
          "new_password": passwordController.text,
          "new_password_confirmation": confirmPassworController.text
        },
      );

      if (response != null && response["status"]!=false) {
        String msg = response["message"].toString();
        print("resetPassword : "+response.toString());
        CustomSnackBar.showSuccess(message: msg);

        Get.offAllNamed(AppRoutes.login);
      }


    } catch (e, stk) {
      printMessage("Exception : " + e.toString() + "\n$stk");
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isCallingApi.value = false;
      CustomLoader.hide();
    }
  }


  /// Dispose controllers
  @override
  void onClose() {
    super.onClose();
  }
}


enum OtpFlowType {
  login,
  forgetPassword,
}
