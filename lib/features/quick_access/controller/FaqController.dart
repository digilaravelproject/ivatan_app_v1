import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/FaqModel.dart';

class FAQController extends GetxController {
  RxList<FAQItem> faqList = <FAQItem>[].obs;

  @override
  void onInit() {
    faqList.addAll([
      FAQItem(
        question: "Is i-Vatan available globally?",
        answer: "Yes, i-Vatan is available in multiple countries worldwide.",
      ),
      FAQItem(
        question: "How can I monetize my content?",
        answer: "You can monetize your content by enabling monetization in settings.",
      ),
      FAQItem(
        question: "Movie Reminders",
        answer: "Enable movie reminders in your notification settings.",
      ),
      FAQItem(
        question: "Payment Settings",
        answer: "Update your payment details in the profile section.",
      ),
    ]);

    super.onInit();
  }

  void toggleExpand(int index) {
    faqList[index].isExpanded.toggle();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Could not open dialer");
    }
  }

  Future<void> openEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Could not open email app");
    }
  }
}
