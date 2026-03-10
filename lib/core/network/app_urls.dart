import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../helper/extensions.dart';

class AppUrls {
  AppUrls._();

  // User Types for account switching
  static const String seller = "seller";
  static const String employer = "employer";

  // Current selected user type (Reactive)
  static RxString selectedUserType = employer.obs;

  static const String baseUrl =
    //  "https://darkorange-baboon-922736.hostingersite.com";
  "https://www.ivatan.in/";
  static const String apiBaseUrl = "$baseUrl";

  static const String imageurl = "https://www.ivatan.in/storage/";

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    
    // Remove leading slash if present to avoid double slashes
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$imageurl$cleanPath";
  }

  static const login = "api/auth/login";
  static const loginOtp = "api/auth/mobile_login";
  static const register = "api/auth/register";
  static const posts  ="api/v1/posts";

  static const verifyForgetPassword  ="api/forgot-password/verify";
  static const changePassword  ="api/forgot-password/reset";
  static const interests  ="api/interests";



  static const allJobs  ="api/v1/jobs";
  static const recruiterJobs = "api/v1/jobs/recruiter";
  static const careerProfile = "api/v1/jobs/my/profile";

  static const sellerProducts = "api/v1/seller/products";
  static const sellerServices = "api/v1/seller/services";

  static const defaultApiKey =
      "1|1yCFcc7ahglUgOL3cftZZ7T83gcyFJreXGlQx0zud042e463";
}
