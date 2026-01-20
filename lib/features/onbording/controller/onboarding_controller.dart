import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/features/auth/persentation/login_screen.dart';
import '../../auth/binding/auth_binding.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;

  final List<OnboardingModel> onboardingList = [
    OnboardingModel(
      image: AppAssets.imgOnbording1,
      title: 'i-connect\n Your Connection, Your Privacy',
      description: 'Connect, talk, share — and build real \n relationships with purpose.',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording2,
      title: 'i-Play & i-clips \n Your Content, Your Ownership',
      description: 'Post reels, videos & thoughts — no algorithms \n dictating your voice.',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording3,
      title: 'i-Mart \n (In-Built Marketplace)',
      description: 'Buy. Sell. Discover — grow your \n business locally and digitally.',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording4,
      title: 'i-QuickHire',
      description: 'Hire fast. Get hired faster — built for \n India’s real workforce.',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording5,
      title: 'i-Secure \n Built on Trust',
      description: 'Your data stays yours. No tracking. \n No manipulation. Ever.',
    ),
  ];

  void updatePage(int index) {
    currentPage.value = index;
  }

  void goToNextPage() {
    if (currentPage.value < onboardingList.length - 1) {
      currentPage.value++;
    } else {
   //   Get.to(LoginPage());
      Get.to(() =>  LoginPage(), binding: AuthBinding());

    }
  }
}
