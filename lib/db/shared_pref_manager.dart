import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/model/res/user_model.dart';

class SharedPrefManager {
  static final SharedPrefManager _instance = SharedPrefManager._internal();

  factory SharedPrefManager() => _instance;

  SharedPrefManager._internal();

  static const String _keyUserData = "_userData";

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save full API response { user: {...}, token: "..." }
  Future<void> saveUserData(Map<String, dynamic> apiResponse) async {
    String jsonString = jsonEncode(apiResponse);
    await _prefs.setString(_keyUserData, jsonString);
  }

  /// Check login status
  bool get isUserLogin => _prefs.getString(_keyUserData) != null;

  /// Get UserModel
  UserModel? get user {
    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      final json = jsonDecode(data);
      return UserModel.fromJson(json);
    }
    return null;
  }

  /// Get Token
  String? get token {
    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      final map = jsonDecode(data);
      return map["token"];
    }
    return null;
  }

  /// Logout
  Future<void> userLogOut() async {
    await _prefs.remove(_keyUserData);
  }

  Future<void> updateUserOnly(Map<String, dynamic> updatedUser) async {
    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      final existing = jsonDecode(data);
      existing["user"] = updatedUser;
      await _prefs.setString(_keyUserData, jsonEncode(existing));
    }
  }
}
