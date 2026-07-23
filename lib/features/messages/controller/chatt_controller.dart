import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/messages/model/chat_data_model.dart';

import '../../../core/network/api_services.dart';
import '../../../core/network/websocket_service.dart';
import '../../../db/shared_pref_manager.dart';
import '../model/chat_model.dart';
import '../../../core/helper/custom_snack_bar.dart';

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
  WebSocketService? _ws;

  @override
  void onInit() {
    fetchInbox();
    fetchInboxGroup();
    _initPresenceListener();
    super.onInit();
  }

  void _initPresenceListener() {
    try {
      _ws = Get.find<WebSocketService>();
      final userId = SharedPrefManager().user?.id;
      if (userId == null) return;

      _ws!.listen("presence.changed", _onPresenceChanged);
      _ws!.subscribe("private-user.$userId");
      log("📡 [ChattController] Subscribed to private-user.$userId for presence");
    } catch (e) {
      log("⚠️ [ChattController] Failed to init presence listener: $e");
    }
  }

  void _onPresenceChanged(dynamic data) {
    try {
      final int userId = data["user_id"] ?? 0;
      final bool isOnline = data["is_online"] ?? false;
      if (userId == 0) return;

      bool updated = false;
      for (int i = 0; i < chatList.length; i++) {
        final chat = chatList[i];
        if (chat.type == "private") {
          final bool isMatch = chat.participants.any((p) => p.userId == userId);
          if (isMatch) {
            chatList[i] = ChatListModel(
              id: chat.id,
              uuid: chat.uuid,
              type: chat.type,
              name: chat.name,
              avatar: chat.avatar,
              isOnline: isOnline,
              isAdmin: chat.isAdmin,
              unreadCount: chat.unreadCount,
              lastMessage: chat.lastMessage,
              updatedAt: chat.updatedAt,
              participantsCount: chat.participantsCount,
              participants: chat.participants,
            );
            updated = true;
          }
        }
      }
      if (updated) {
        chatList.refresh();
        filteredChatList.assignAll(chatList);
      }
    } catch (e) {
      log("⚠️ [ChattController] _onPresenceChanged error: $e");
    }
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

  Future<int?> createSinglePrivateChat(int userId) async {
    try {
      final response = await api.callPost(
        "api/v1/chats/private",
        data: {"other_user_id": userId},
      );

      print("createSinglePrivateChat : "+userId.toString());

      if (response != null) {
        if (response["status"] == true) {
          final data = response["data"];

          if (data is Map) {
            final map = Map<String, dynamic>.from(data);
            return map["id"];
          }
        } else if (response["message"] != null) {
          CustomSnackBar.showError(message: response["message"]);
        }
      }
    } catch (e, stk) {
      print("createSinglePrivateChat error: $e\n$stk");
    }

    return null;
  }

  @override
  void onClose() {
    try {
      final userId = SharedPrefManager().user?.id;
      if (_ws != null && userId != null) {
        _ws!.removeListener("presence.changed", _onPresenceChanged);
        _ws!.unsubscribe("private-user.$userId");
      }
    } catch (e) {
      log("⚠️ [ChattController] onClose error: $e");
    }
    searchController.dispose();
    super.onClose();
  }
}
