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
  static const String _keyRegisteredProfileType = "_registeredProfileType";
  static const String _keyRegisteredProfileSubType = "_registeredProfileSubType";

  Future<void> setActiveProfileType(String? type) async {
    if (type != null && type.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, type);
    } else {
      await _prefs.remove(_keyActiveProfileType);
    }
  }

  String? get activeProfileType => _prefs.getString(_keyActiveProfileType);

  Future<void> setRegisteredProfileType(String? type) async {
    if (type != null && type.isNotEmpty) {
      await _prefs.setString(_keyRegisteredProfileType, type);
    } else {
      await _prefs.remove(_keyRegisteredProfileType);
    }
  }

  String? get registeredProfileType => _prefs.getString(_keyRegisteredProfileType);

  Future<void> setRegisteredProfileSubType(String? subType) async {
    if (subType != null && subType.isNotEmpty) {
      await _prefs.setString(_keyRegisteredProfileSubType, subType);
    } else {
      await _prefs.remove(_keyRegisteredProfileSubType);
    }
  }

  String? get registeredProfileSubType => _prefs.getString(_keyRegisteredProfileSubType);

  static const String _keyPersonalGatewaySubId = "_personalGatewaySubId";
  static const String _keyPersonalGatewayOrderId = "_personalGatewayOrderId";
  static const String _keyPersonalGatewayPaymentId = "_personalGatewayPaymentId";

  /// Save full API response { user: {...}, token: "..." }
  Future<void> saveUserData(Map<String, dynamic> apiResponse) async {
    // Clear any stale cached profile config and exclusive purchase flags from previous session
    await _prefs.remove("_profileConfig");
    await _prefs.remove(_keyExclusivePurchased);
    await _prefs.remove(_keyPersonalGatewaySubId);
    await _prefs.remove(_keyPersonalGatewayOrderId);
    await _prefs.remove(_keyPersonalGatewayPaymentId);

    // Extract active profile type from response if available
    final userData = apiResponse["user"] is Map<String, dynamic>
        ? apiResponse["user"] as Map<String, dynamic>
        : (apiResponse["data"] is Map<String, dynamic> && (apiResponse["data"] as Map)["user"] is Map
            ? (apiResponse["data"] as Map)["user"] as Map<String, dynamic>
            : apiResponse);
    String? activeType;
    if (userData["active_profile"] is Map) {
      activeType = userData["active_profile"]["type"]?.toString();
    }
    activeType ??= userData["profile_type"]?.toString();

    // Check if user has a registered non-personal profile in profiles list
    if (registeredProfileType == null || registeredProfileType!.isEmpty) {
      if (userData["profiles"] is List) {
        for (final p in userData["profiles"] as List) {
          if (p is Map) {
            final t = p["type"]?.toString().toLowerCase().trim();
            if (t != null && t.isNotEmpty && t != 'personal' && t != 'personal_profile') {
              await setRegisteredProfileType(t);
              break;
            }
          }
        }
      }
    }

    if (activeType != null && activeType.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, activeType);
    }

    _extractAndSavePersonalGatewayIds(userData);

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

  /// Get raw user data map
  Map<String, dynamic>? get rawUserData {
    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          if (decoded["user"] is Map<String, dynamic>) {
            return decoded["user"] as Map<String, dynamic>;
          }
          return decoded;
        }
      } catch (_) {}
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
    await _prefs.remove(_keyRegisteredProfileType);
    await _prefs.remove(_keyRegisteredProfileSubType);
    await _prefs.remove(_keyPersonalGatewaySubId);
    await _prefs.remove(_keyPersonalGatewayOrderId);
    await _prefs.remove(_keyPersonalGatewayPaymentId);
  }

  static const String _keyExclusivePurchased = "_exclusivePurchased";

  Future<void> setExclusivePurchased(bool value) async {
    await _prefs.setBool(_keyExclusivePurchased, value);
  }

  bool get isExclusivePurchased => _prefs.getBool(_keyExclusivePurchased) ?? false;

  void _extractAndSavePersonalGatewayIds(Map<String, dynamic> userData) {
    Map<String, dynamic> u = userData;
    if (u["user"] is Map) {
      u = u["user"] as Map<String, dynamic>;
    } else if (u["data"] is Map && (u["data"] as Map)["user"] is Map) {
      u = (u["data"] as Map)["user"] as Map<String, dynamic>;
    }

    Map<String, dynamic>? subMap;
    Map<String, dynamic>? ap;

    // 1. Check active_profile
    if (u["active_profile"] is Map) {
      ap = u["active_profile"] as Map<String, dynamic>;
      final type = ap["type"]?.toString().toLowerCase().trim();
      if ((type == 'personal' || type == 'personal_profile') && ap["active_subscription"] is Map) {
        subMap = ap["active_subscription"] as Map<String, dynamic>;
      }
    }

    // 2. Check profiles list for personal profile
    if (subMap == null && u["profiles"] is List) {
      for (final p in u["profiles"] as List) {
        if (p is Map) {
          final pType = p["type"]?.toString().toLowerCase().trim();
          if (pType == 'personal' || pType == 'personal_profile') {
            if (p["active_subscription"] is Map) {
              subMap = p["active_subscription"] as Map<String, dynamic>;
              break;
            }
          }
        }
      }
    }

    // 3. Fallback: check active_profile's active_subscription regardless of type if active is personal
    if (subMap == null && ap != null && ap["active_subscription"] is Map) {
      subMap = ap["active_subscription"] as Map<String, dynamic>;
    }

    // 4. Fallback: top-level active_subscription
    if (subMap == null && u["active_subscription"] is Map) {
      subMap = u["active_subscription"] as Map<String, dynamic>;
    }

    final subId = (subMap?["gateway_subscription_id"] ?? ap?["gateway_subscription_id"])?.toString().trim();
    final orderId = (subMap?["gateway_order_id"] ?? ap?["gateway_order_id"])?.toString().trim();
    final paymentId = (subMap?["gateway_payment_id"] ?? ap?["gateway_payment_id"])?.toString().trim();

    bool isValid(String? val) =>
        val != null &&
        val.isNotEmpty &&
        val.toLowerCase() != 'null' &&
        val.toLowerCase() != 'undefined';

    if (isValid(subId) && isValid(orderId) && isValid(paymentId)) {
      _prefs.setString(_keyPersonalGatewaySubId, subId!);
      _prefs.setString(_keyPersonalGatewayOrderId, orderId!);
      _prefs.setString(_keyPersonalGatewayPaymentId, paymentId!);
    } else {
      _prefs.remove(_keyPersonalGatewaySubId);
      _prefs.remove(_keyPersonalGatewayOrderId);
      _prefs.remove(_keyPersonalGatewayPaymentId);
    }
  }

  bool _checkRawUserDataGatewayIds(Map<String, dynamic> userData) {
    Map<String, dynamic> u = userData;
    if (u["user"] is Map) {
      u = u["user"] as Map<String, dynamic>;
    } else if (u["data"] is Map && (u["data"] as Map)["user"] is Map) {
      u = (u["data"] as Map)["user"] as Map<String, dynamic>;
    }

    Map<String, dynamic>? subMap;
    Map<String, dynamic>? ap;

    if (u["active_profile"] is Map) {
      ap = u["active_profile"] as Map<String, dynamic>;
      final type = ap["type"]?.toString().toLowerCase().trim();
      if ((type == 'personal' || type == 'personal_profile') && ap["active_subscription"] is Map) {
        subMap = ap["active_subscription"] as Map<String, dynamic>;
      }
    }
    if (subMap == null && u["profiles"] is List) {
      for (final p in u["profiles"] as List) {
        if (p is Map) {
          final pType = p["type"]?.toString().toLowerCase().trim();
          if (pType == 'personal' || pType == 'personal_profile') {
            if (p["active_subscription"] is Map) {
              subMap = p["active_subscription"] as Map<String, dynamic>;
              break;
            }
          }
        }
      }
    }
    if (subMap == null && ap != null && ap["active_subscription"] is Map) {
      subMap = ap["active_subscription"] as Map<String, dynamic>;
    }
    if (subMap == null && u["active_subscription"] is Map) {
      subMap = u["active_subscription"] as Map<String, dynamic>;
    }

    final subId = (subMap?["gateway_subscription_id"] ?? ap?["gateway_subscription_id"])?.toString().trim();
    final orderId = (subMap?["gateway_order_id"] ?? ap?["gateway_order_id"])?.toString().trim();
    final paymentId = (subMap?["gateway_payment_id"] ?? ap?["gateway_payment_id"])?.toString().trim();

    bool isValid(String? val) =>
        val != null &&
        val.isNotEmpty &&
        val.toLowerCase() != 'null' &&
        val.toLowerCase() != 'undefined';

    final result = isValid(subId) && isValid(orderId) && isValid(paymentId);
    if (result) {
      _prefs.setString(_keyPersonalGatewaySubId, subId!);
      _prefs.setString(_keyPersonalGatewayOrderId, orderId!);
      _prefs.setString(_keyPersonalGatewayPaymentId, paymentId!);
    }
    return result;
  }

  /// Individual getters for stored personal gateway IDs
  String? get personalGatewaySubscriptionId => _prefs.getString(_keyPersonalGatewaySubId);
  String? get personalGatewayOrderId => _prefs.getString(_keyPersonalGatewayOrderId);
  String? get personalGatewayPaymentId => _prefs.getString(_keyPersonalGatewayPaymentId);

  /// Returns true if all 3 gateway subscription IDs are non-null and not empty
  bool get hasPersonalSubscriptionGatewayIds {
    final subId = personalGatewaySubscriptionId;
    final orderId = personalGatewayOrderId;
    final paymentId = personalGatewayPaymentId;

    bool isValid(String? val) =>
        val != null &&
        val.isNotEmpty &&
        val.toLowerCase() != 'null' &&
        val.toLowerCase() != 'undefined';

    if (isValid(subId) && isValid(orderId) && isValid(paymentId)) {
      return true;
    }

    // Fallback: check cached user data if keys were not written yet
    try {
      final raw = rawUserData;
      if (raw != null) {
        return _checkRawUserDataGatewayIds(raw);
      }
    } catch (_) {}

    return false;
  }

  Future<void> updateUserOnly(Map<String, dynamic> updatedUser) async {
    String? activeType;
    if (updatedUser["active_profile"] is Map) {
      activeType = updatedUser["active_profile"]["type"]?.toString();
    }
    activeType ??= updatedUser["profile_type"]?.toString();

    // Check if user has a registered non-personal profile in profiles list
    if (registeredProfileType == null || registeredProfileType!.isEmpty) {
      if (updatedUser["profiles"] is List) {
        for (final p in updatedUser["profiles"] as List) {
          if (p is Map) {
            final t = p["type"]?.toString().toLowerCase().trim();
            if (t != null && t.isNotEmpty && t != 'personal' && t != 'personal_profile') {
              await setRegisteredProfileType(t);
              break;
            }
          }
        }
      }
    }

    if (activeType != null && activeType.isNotEmpty) {
      await _prefs.setString(_keyActiveProfileType, activeType);
    }

    _extractAndSavePersonalGatewayIds(updatedUser);

    String? data = _prefs.getString(_keyUserData);
    if (data != null) {
      final existing = jsonDecode(data);
      if (existing is Map<String, dynamic>) {
        if (existing["user"] is Map) {
          existing["user"] = updatedUser;
        } else if (existing["data"] is Map && (existing["data"] as Map)["user"] is Map) {
          (existing["data"] as Map)["user"] = updatedUser;
        } else {
          existing["user"] = updatedUser;
        }
        await _prefs.setString(_keyUserData, jsonEncode(existing));
      }
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
