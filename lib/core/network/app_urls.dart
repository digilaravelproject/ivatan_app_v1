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
    if (path == null || path.trim().isEmpty) return "";
    String p = path.trim();
    if (p.toLowerCase().startsWith('http')) return p;
    
    // Remove leading slash if present to avoid double slashes
    String cleanPath = p.startsWith('/') ? p.substring(1) : p;
    return "$imageurl$cleanPath";
  }

  static const login = "api/auth/login";
  static const loginOtp = "api/auth/mobile_login";
  static const register = "api/auth/register";
  static const posts  ="api/v1/posts";
  static const profileConfig = "api/v1/profiles/config";
  static const profileSwitch = "api/v1/profiles/switch";
  static const profileTypes = "api/profile-types";
  static const profileSwitchRequests = "api/v1/profile-switch-requests";
  static const updateProfile = "api/v1/auth/update";
  static String userProfileUrl(String username) => "api/v1/users/$username";

  static const verifyForgetPassword  ="api/forgot-password/verify";
  static const changePassword  ="api/forgot-password/reset";
  static const interests  ="api/interests";



  static const allJobs  ="api/v1/jobs";
  static const recruiterJobs = "api/v1/jobs/recruiter";
  static const careerProfile = "api/v1/jobs/my/profile";

  static const sellerProducts = "api/v1/seller/products";
  static const sellerServices = "api/v1/services";                  // marketplace services list (GET)
  static const marketplaceServices = "api/v1/marketplace/services"; // marketplace browse (GET)
  static const sellerManageServices = "api/v1/seller/services";     // seller CRUD: GET list / POST create
  static String sellerManageServiceDetail(dynamic id) => "api/v1/seller/services/$id"; // PUT/DELETE
  static const marketplaceProducts = "api/v1/marketplace/products";
  static String marketplaceProductDetail(dynamic userId) => "api/v1/marketplace/product/$userId";
  static String marketplaceServiceDetail(dynamic userId) => "api/v1/marketplace/service/$userId";
  static String marketplaceProductDetailItem(dynamic id) => "api/v1/marketplace/products/$id";
  static String sellerServiceDetail(dynamic id) => "api/v1/services/$id";
  static const addresses = "api/v1/addresses";
  static const cart = "api/v1/cart";
  static const checkout = "api/v1/checkout";
  static const razorpayOrder = "api/v1/payment/razorpay/order";
  static const razorpayVerify = "api/v1/payment/razorpay/verify";
  static const enquiries = "api/v1/enquiries";
  static const myEnquiries = "api/v1/user/my-enquiries";
  //static const sellerEnquiries = "api/v1/seller/enquiries";
  static const sellerEnquiries = "api/v1/user/my-enquiries";
  static const sellerEnquiriesStats = "api/v1/seller/enquiries/stats";
  static String sellerEnquiryStatusUpdate(int id) => "api/v1/seller/enquiries/$id/status";
  static String deleteEnquiry(int id) => "api/v1/seller/enquiries/$id";
  static const financial = "api/v1/seller/financials";
  static const orders = "api/v1/orders";
  static String orderDetail(int id) => "api/v1/orders/$id";
  static const sellerOrders = "api/v1/seller/orders";
  static String sellerOrderDetail(int id) => "api/v1/seller/orders/$id";
  static String sellerOrderStatusUpdate(int id) => "api/v1/seller/orders/$id/status";
  static const sellerStats = "api/v1/seller/dashboard/stats";

  static const feedPostImages = "api/v1/posts/feed/images";
  static const storyFeed = "api/v1/stories/feed";
  static String likePost(int id) => "api/v1/posts/$id/like";
  static String likeStory(int id) => "api/v1/stories/$id/like";
  static String reportPost(int id) => "api/v1/posts/$id/report";

  // --------- FEED / SEARCH -----------//
  static const feedTrending = "api/v1/posts/feed/trending";
  static const feedTrendingInterests = "api/v1/posts/feed/trending/interests";
  static const feedForYou = "api/v1/posts/feed/for-you";
  static const banners = "api/v1/banners";
  static const logout = "api/v1/auth/logout";
  static const deleteAccount = "api/v1/auth/delete-account";
  static String blockUser(int id) => "api/v1/users/$id/block";
  static String markInterested(int id) => "api/v1/posts/$id/interested";
  static String markNotInterested(int id) => "api/v1/posts/$id/not-interested";
  static String bookmarkPost(int id) => "api/v1/posts/$id/bookmark";
  static const myBookmarks = "api/v1/user/bookmarks";
  static const blockedUsers = "api/v1/user/blocked-users";
  static const String chats = "api/v1/chats";
  static const String liveChatGroups = "api/v1/live-chat-groups";
  static String liveChatGroupDetail(dynamic id) => "api/v1/live-chat-groups/$id";
  static String chatMessages(dynamic chatId) => "api/v1/chats/$chatId/messages";


  //    NOTIFICATIONS

  static const String registerDeviceToken = "api/v1/notifications/device-tokens";

  static const String deleteDeviceToken = "api/v1/notifications/device-tokens";
  static const String getNotifications = "api/v1/notifications";
  static const String unreadCount = "api/v1/notifications/unread-count";
  static const String markNotificationRead = "api/v1/notifications/mark-read";
  static const String markAllNotificationsRead = "api/v1/notifications/mark-all-read";

  static const defaultApiKey =
      "1|1yCFcc7ahglUgOL3cftZZ7T83gcyFJreXGlQx0zud042e463";
}
