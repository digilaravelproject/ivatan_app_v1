import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterController extends GetxController {
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Could not open dialer");
    }
  }
}
