class AppUrls {
  AppUrls._();

  static const String baseUrl =
    //  "https://darkorange-baboon-922736.hostingersite.com";
  "https://www.ivatan.in/";
  static const String apiBaseUrl = "$baseUrl";

  static const String imageurl = "https://www.ivatan.in/storage/";

  static const login = "api/auth/login";
  static const loginOtp = "api/auth/mobile_login";
  static const register = "api/auth/register";
  static const posts  ="api/v1/posts";

  static const verifyForgetPassword  ="api/forgot-password/verify";
  static const changePassword  ="api/forgot-password/reset";
  static const interests  ="api/interests";



  static const defaultApiKey =
      "1|1yCFcc7ahglUgOL3cftZZ7T83gcyFJreXGlQx0zud042e463";
}
