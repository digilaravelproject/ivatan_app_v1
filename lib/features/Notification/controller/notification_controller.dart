import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../dashboard/controller/homeController.dart';
import '../repository/notification_repository.dart';
import '../services/fcm_service.dart';
import '../data/model/notification_response_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  final RxBool isLoading = false.obs;
  final RxString fcmToken = ''.obs;

  // Notification list state variables
  final RxList<NotificationApiItem> notificationsList = <NotificationApiItem>[].obs;
  final RxList<NotificationApiItem> unreadNotificationsList = <NotificationApiItem>[].obs;
  final RxBool isListLoading = false.obs;
  final RxBool isUnreadListLoading = false.obs;

  Future<void> fetchNotificationsList() async {
    try {
      isListLoading.value = true;
      final response = await repository.fetchNotifications();
      if (response != null && response.success && response.data != null) {
        notificationsList.assignAll(response.data!.data);
      }
    } catch (e) {
      print("Error fetching notifications list: $e");
    } finally {
      isListLoading.value = false;
    }
  }

  Future<void> fetchUnreadNotificationsList() async {
    try {
      isUnreadListLoading.value = true;
      final response = await repository.fetchNotifications(queryParams: {
        "only": "unread",
        "per_page": "20",
      });
      if (response != null && response.success && response.data != null) {
        unreadNotificationsList.assignAll(response.data!.data);
      }
    } catch (e) {
      print("Error fetching unread notifications list: $e");
    } finally {
      isUnreadListLoading.value = false;
    }
  }

  bool _listenersAdded = false;

  Future<void> initNotification() async {
    await FcmService.requestPermission();

    await registerCurrentDeviceToken();

    listenTokenRefresh();

    setupNotificationListeners();

    await checkTerminatedNotification();
  }

  Future<void> registerCurrentDeviceToken() async {
    try {
      isLoading.value = true;

      final token = await FcmService.getToken();

      if (token == null || token.isEmpty) {
        print("FCM token null hai");
        return;
      }

      fcmToken.value = token;

      final response = await repository.registerDeviceToken(
        token: token,
        device: FcmService.deviceType,
      );

      print("Device Token Register: ${response?.message}");
    } catch (e) {
      print("Register FCM Token Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void listenTokenRefresh() {
    FcmService.tokenRefresh.listen((newToken) async {
      print("New FCM Token: $newToken");

      fcmToken.value = newToken;

      await repository.registerDeviceToken(
        token: newToken,
        device: FcmService.deviceType,
      );
    });
  }

  void setupNotificationListeners() {
    if (_listenersAdded) return;
    _listenersAdded = true;

    FcmService.listenForegroundNotification();

    FcmService.listenNotificationClick(
      onClick: handleNotificationNavigation,
    );
  }

  Future<void> checkTerminatedNotification() async {
    final RemoteMessage? message = await FcmService.getInitialMessage();

    if (message != null) {
      print("App terminated se notification click hua");
      handleNotificationNavigation(message);
    }
  }

  void handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;

    print("Notification Data: $data");

    final type = data['type'];
    final id = data['id'] ?? data['reference_id'];

    if (type == 'leave') {
      // Get.toNamed('/leave-details', arguments: {'id': id});
    } else if (type == 'attendance') {
      // Get.toNamed('/attendance-details', arguments: {'id': id});
    } else if (type == 'announcement') {
      // Get.toNamed('/announcement-details', arguments: {'id': id});
    } else {
      // Get.toNamed('/notifications');
    }
  }

  Future<void> deleteTokenOnLogout() async {
    try {
      final token = await FcmService.getToken();

      if (token == null || token.isEmpty) return;

      final response = await repository.deleteDeviceToken(
        token: token,
      );

      print("Device Token Delete: ${response?.message}");
    } catch (e) {
      print("Delete FCM Token Error: $e");
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final success = await repository.markAsRead(notificationId);
      if (success) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchUnreadNotificationCount();
        }
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final success = await repository.markAllAsRead();
      if (success) {
        final nowStr = DateTime.now().toIso8601String();
        final updatedList = notificationsList.map((item) {
          if (item.readAt == null) {
            return NotificationApiItem(
              id: item.id,
              type: item.type,
              innerData: item.innerData,
              readAt: nowStr,
              createdAt: item.createdAt,
            );
          }
          return item;
        }).toList();

        notificationsList.assignAll(updatedList);
        unreadNotificationsList.clear();

        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchUnreadNotificationCount();
        }
      }
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }
}