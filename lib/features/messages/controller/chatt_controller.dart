import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/messages/model/chat_data_model.dart';

import '../../../core/network/api_services.dart';
import '../model/chat_model.dart';

class ChattController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ChatListModel> chatList = <ChatListModel>[].obs;
  RxList<ChatListModel> groupChatList = <ChatListModel>[].obs;
  RxBool showSearch = false.obs;
  TextEditingController searchController = TextEditingController();

  RxList<ChatListModel> filteredChatList = <ChatListModel>[].obs;
  RxList<ChatListModel> filteredGroupList = <ChatListModel>[].obs;

  Pagination? pagination;

  final ApiServices api = ApiServices();

  @override
  void onInit() {
    fetchInbox();
    fetchInboxGroup();
    super.onInit();
  }

  Future<void> fetchInboxGroup() async {
    isLoading.value = true;
    try {
      final response = await api.callGet("api/v1/chats?filter=groups");
      if (response != null && response["status"] == true) {
        var apiList = response['data']['chats']['data'] as List;
        groupChatList.assignAll(apiList.map((e) => ChatListModel.fromJson(e)));
        filteredGroupList.assignAll(apiList.map((e) => ChatListModel.fromJson(e)));
        print("responsechatt : "+response.toString());
      } else {
        groupChatList.clear();
      }
    } catch (e, stk) {
      log("FetchInbox Error: $e,\n$stk");
      groupChatList.clear();
    }
    isLoading.value = false;
  }

  Future<void> fetchInbox({String? filter}) async {
    isLoading.value = true;

    try {
      /// query params build karo
      String url = "api/v1/chats";
      if (filter != null) {
        url = "$url?filter=$filter";
      }

      final response = await api.callGet(url);

      if (response != null && response["status"] == true) {
        var apiList = response['data']['chats']['data'] as List;

        final list =
        apiList.map((e) => ChatListModel.fromJson(e)).toList();

        chatList.assignAll(list);
        filteredChatList.assignAll(list);
      } else {
        chatList.clear();
        filteredChatList.clear();
      }
    } catch (e, stk) {
      log("FetchInbox Error: $e\n$stk");
      chatList.clear();
      filteredChatList.clear();
    }

    isLoading.value = false;
  }

  void searchedPerson(String query) {
    if (query.isEmpty) {
      filteredChatList.assignAll(chatList);
    } else {
      filteredChatList.assignAll(
        chatList.where((user) =>
        user.name.toLowerCase().contains(query.toLowerCase())
          //  || user.name.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }

  void searchedGroup(String query) {
    if (query.isEmpty) {
      filteredGroupList.assignAll(groupChatList);
    } else {
      filteredGroupList.assignAll(
        groupChatList.where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase())
          //  || user.name.toLowerCase().contains(query.toLowerCase())
        ),
      );
    }
  }

/*
  Future<void> createPrivateChat( int chatId) async {
    isLoading.value = true;

    try {
      final response = await api.callPost("api/v1/chats/private", data: {"other_user_id" : chatId});

      if (response != null && response["status"] == true) {

        final data = response['data'];

        // CASE 1: List response
        if (data is List) {
          chatList.assignAll(
            data
                .map((e) => ChatListModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        }
        // CASE 2: Single object response (current case)
        else if (data is Map) {
          chatList.assignAll([
            ChatListModel.fromJson(Map<String, dynamic>.from(data)),
          ]);
        }

        print("responsechatt : $response");
      } else {
        chatList.clear();
      }
    } catch (e, stk) {
      log("FetchInbox Error: $e,\n$stk");
      chatList.clear();
    }

    isLoading.value = false;
  }
*/

  Future<int?> createSinglePrivateChat(int userId) async {
    try {
      final response = await api.callPost(
        "api/v1/chats/private",
        data: {"other_user_id": userId},
      );

      print("createSinglePrivateChat : "+userId.toString());

      if (response != null && response["status"] == true) {
        final data = response["data"];

        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          return map["id"]; // 👈 yaha se chat id milegi
        }
      }
    } catch (e, stk) {
      print("createSinglePrivateChat error: $e\n$stk");
    }

    return null; // fail case
  }

}
