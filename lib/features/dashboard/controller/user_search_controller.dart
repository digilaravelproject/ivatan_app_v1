import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../data/model/user_search_model.dart';

class UserSearchController extends GetxController {
  var isLoading = false.obs;
  var users = <UserSearchModel>[].obs;
  var query = ''.obs;
  Timer? _debounce;

  void searchUsers(String value) {
    query.value = value;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.value.trim().isNotEmpty) {
        fetchUsers(query.value);
      } else {
        users.clear();
      }
    });
  }

  Future<void> fetchUsers(String q) async {
    isLoading.value = true;

    try {
      final token = SharedPrefManager().token;
      if (token == null) {
        isLoading.value = false;
        return;
      }

      final url = '${AppUrls.apiBaseUrl}api/v1/users/search?q=$q&per_page=20';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final result = UserSearchResponse.fromJson(decodedData);
        
        if (result.success == true && result.data != null) {
          users.assignAll(result.data!);
        } else {
          users.clear();
        }
      } else {
        users.clear();
      }
    } catch (e) {
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
