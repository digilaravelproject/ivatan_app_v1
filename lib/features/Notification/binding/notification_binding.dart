import 'package:get/get.dart';
import '../controller/notification_controller.dart';
import '../repository/notification_repository.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
          () => NotificationRepository(),
    );

    Get.lazyPut<NotificationController>(
          () => NotificationController(
        repository: Get.find<NotificationRepository>(),
      ),
    );
  }
}