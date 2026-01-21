import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../../../core/network/api_services.dart';

class InterestController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<dynamic> interestData = <dynamic>[].obs;

  final ApiServices api = ApiServices();

  @override
  void onInit() {
    super.onInit();
    // ⚡️ OPTIMISTIC UI: Load fallback data IMMEDIATELY
    // This ensures NO loading screen is ever shown to the user.
    interestData.value = _fallbackData;
    fetchInterests();
  }

  Future<void> fetchInterests() async {
    // Note: We do NOT set isLoading = true here to avoid showing a spinner.
    // The user already sees the fallback data. We update silently.
    
    try {
      final response = await api.callGet("api/interests");

      if (response != null && response["status"] == true) {
        // Silently update with fresh server data
        interestData.value = response["data"];
      } 
    } catch (e) {
      print("⚠️ Silent background fetch failed: $e");
      // No action needed, user already has fallback data
    } 
  }

  // ✅ Hardcoded data to ensure UI works even if offline
  final List<dynamic> _fallbackData = [
    {
      "category": "Business & Finance",
      "interests": [
        "Startups & Entrepreneurship",
        "Investing & Stock Market",
        "Personal Finance",
        "Real Estate",
        "Marketing & Sales",
        "Crypto / Blockchain"
      ]
    },
    {
      "category": "Education & Learning",
      "interests": [
        "Coding / IT",
        "Business & Management",
        "Language Learning",
        "Competitive Exams",
        "Science & Research"
      ]
    },
    {
      "category": "Entertainment & Lifestyle",
      "interests": ["Movies & Series", "Music"]
    },
    {"category": "IT", "interests": ["Web Development", "App Development"]},
    {
      "category": "Jobs & Careers",
      "interests": [
        "Quick Hiring / Part-time",
        "Freelancing / Remote Work",
        "Corporate Jobs",
        "Government Jobs",
        "Skill Development"
      ]
    },
    {
      "category": "Technology",
      "interests": [
        "Web Development",
        "Software Engineering",
        "AI / Machine Learning",
        "Mobile Apps",
        "Cybersecurity",
        "Gaming / eSports"
      ]
    }
  ];
}
