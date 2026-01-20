import 'package:get/get.dart';

import '../controller/chat_message_controller.dart';
class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatMessagesController());
  }
}
