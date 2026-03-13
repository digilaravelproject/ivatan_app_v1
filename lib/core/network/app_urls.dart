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
  static const sellerServices = "api/v1/services";
  static const marketplaceServices = "api/v1/marketplace/services";
  static const cart = "api/v1/cart";
  static const checkout = "api/v1/checkout";
  static const razorpayOrder = "api/v1/payment/razorpay/order";
  static const razorpayVerify = "api/v1/payment/razorpay/verify";
  static const enquiries = "api/v1/enquiries";
  static const sellerEnquiries = "api/v1/seller/enquiries";
  static const sellerEnquiriesStats = "api/v1/seller/enquiries/stats";
  static String sellerEnquiryStatusUpdate(int id) => "api/v1/seller/enquiries/$id/stats";
  static String deleteEnquiry(int id) => "api/v1/seller/enquiries/$id";
  static const financial = "api/v1/seller/financials";
  static const orders = "api/v1/orders";
  static String orderDetail(int id) => "api/v1/orders/$id";
  static const sellerOrders = "api/v1/seller/orders";
  static String sellerOrderDetail(int id) => "api/v1/seller/orders/$id";
  static String sellerOrderStatusUpdate(int id) => "api/v1/seller/orders/$id/status";
  static const sellerStats = "api/v1/seller/dashboard/stats";

  static const defaultApiKey =
      "1|1yCFcc7ahglUgOL3cftZZ7T83gcyFJreXGlQx0zud042e463";
}
