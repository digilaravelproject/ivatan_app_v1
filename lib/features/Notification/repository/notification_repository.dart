import 'package:get/get.dart';
import '../../../core/network/api_services.dart';
import '../../../core/network/app_urls.dart';
import '../data/model/device_token_response_model.dart';
import '../data/model/notification_response_model.dart';

class NotificationRepository {
  final ApiServices _apiServices = Get.find<ApiServices>();

  Future<DeviceTokenResponseModel?> registerDeviceToken({
    required String token,
    required String device,
  }) async {
    final response = await _apiServices.callPost(
      AppUrls.registerDeviceToken,
      data: {
        "token": token,
        "device": device,
      },
    );

    if (response == null) return null;

    return DeviceTokenResponseModel.fromJson(response);
  }

  Future<DeviceTokenResponseModel?> deleteDeviceToken({
    required String token,
  }) async {
    final response = await _apiServices.callDelete(
      AppUrls.deleteDeviceToken,
      data: {
        "token": token,
      },
    );

    if (response == null) return null;

    return DeviceTokenResponseModel.fromJson(response);
  }

  Future<NotificationsResponseModel?> fetchNotifications({Map<String, dynamic>? queryParams}) async {
    final response = await _apiServices.callGet(
      AppUrls.getNotifications,
      queryParams: queryParams,
    );

    if (response == null) return null;

    return NotificationsResponseModel.fromJson(response);
  }

  Future<int?> fetchUnreadCount() async {
    final response = await _apiServices.callGet(
      AppUrls.unreadCount,
    );

    if (response == null || response['success'] != true) return null;

    return response['unread'] as int?;
  }

  Future<bool> markAsRead(String notificationId) async {
    final response = await _apiServices.callPost(
      AppUrls.markNotificationRead,
      data: {
        "notification_id": notificationId,
      },
    );

    if (response == null || response['success'] != true) return false;
    return true;
  }

  Future<bool> markAllAsRead() async {
    final response = await _apiServices.callPost(
      AppUrls.markAllNotificationsRead,
      data: {},
    );

    if (response == null || response['success'] != true) return false;
    return true;
  }
}