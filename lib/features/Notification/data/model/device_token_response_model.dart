class DeviceTokenResponseModel {
  final bool success;
  final String message;

  DeviceTokenResponseModel({
    required this.success,
    required this.message,
  });

  factory DeviceTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}