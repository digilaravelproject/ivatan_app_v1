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
      title: '',
      description: '',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording2,
      title: '',
      description: '',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording3,
      title: '',
      description: '',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording4,
      title: '',
      description: '',
    ),
    OnboardingModel(
      image: AppAssets.imgOnbording5,
      title: '',
      description: '',
    ),
  ];

  void updatePage(int index) {
    currentPage.value = index;
  }

  void goToNextPage() {
    if (currentPage.value < onboardingList.length - 1) {
      currentPage.value++;
    } else {
      skipToLogin();
    }
  }

  void skipToLogin() {
    Get.offAll(() => LoginPage(), binding: AuthBinding());
  }
}
