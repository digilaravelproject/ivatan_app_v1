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

  static const String _keyActiveProfileType = "_activeProfileType";

  Future<void> setActiveProfileType(String? type) async {
    if (type != null && type.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, type);
    } else {
      await _prefs.remove(_keyActiveProfileType);
    }
  }

  String? get activeProfileType => _prefs.getString(_keyActiveProfileType);

  /// Save full API response { user: {...}, token: "..." }
  Future<void> saveUserData(Map<String, dynamic> apiResponse) async {
    // Clear any stale cached profile config and exclusive purchase flags from previous session
    await _prefs.remove("_profileConfig");
    await _prefs.remove(_keyExclusivePurchased);
    await _prefs.remove(_keyActiveProfileType);

    // Extract active profile type from response if available
    final userData = apiResponse["user"] is Map<String, dynamic>
        ? apiResponse["user"] as Map<String, dynamic>
        : apiResponse;
    String? activeType;
    if (userData["active_profile"] is Map) {
      activeType = userData["active_profile"]["type"]?.toString();
    }
    activeType ??= userData["profile_type"]?.toString();
    if (activeType != null && activeType.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, activeType);
    }

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
    await _prefs.remove("_profileConfig");
    await _prefs.remove(_keyExclusivePurchased);
    await _prefs.remove(_keyActiveProfileType);
  }

  static const String _keyExclusivePurchased = "_exclusivePurchased";

  Future<void> setExclusivePurchased(bool value) async {
    await _prefs.setBool(_keyExclusivePurchased, value);
  }

  bool get isExclusivePurchased => _prefs.getBool(_keyExclusivePurchased) ?? false;

  Future<void> updateUserOnly(Map<String, dynamic> updatedUser) async {
    String? activeType;
    if (updatedUser["active_profile"] is Map) {
      activeType = updatedUser["active_profile"]["type"]?.toString();
    }
    activeType ??= updatedUser["profile_type"]?.toString();
    if (activeType != null && activeType.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, activeType);
    }

    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      final existing = jsonDecode(data);
      existing["user"] = updatedUser;
      await _prefs.setString(_keyUserData, jsonEncode(existing));
    }
  }

  /// Save Profile Config JSON
  Future<void> saveProfileConfig(Map<String, dynamic> config) async {
    await _prefs.setString("_profileConfig", jsonEncode(config));
  }

  /// Get Profile Config JSON map
  Map<String, dynamic>? get profileConfig {
    String? data = _prefs.getString("_profileConfig");
    if (data != null) {
      try {
        return jsonDecode(data) as Map<String, dynamic>?;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
