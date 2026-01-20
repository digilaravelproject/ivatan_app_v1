import 'package:get/get_rx/src/rx_types/rx_types.dart';

class FAQItem {
  final String question;
  final String answer;
  RxBool isExpanded = false.obs;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
