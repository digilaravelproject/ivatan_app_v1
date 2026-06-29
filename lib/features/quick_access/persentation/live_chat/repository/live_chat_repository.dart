import 'dart:io';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../model/chat_inbox_model.dart';
import '../model/chat_message_model.dart';
import '../model/live_chat_group_details_model.dart';

// =========================================================================
// 🚀 DEDICATED REPOSITORY PATTERN LAYER FOR LIVE CHAT ENDPOINTS
// =========================================================================
class LiveChatRepository {
  final ApiServices _api = Get.put(ApiServices());

  /// Fetch chats listing (Groups / Unread / Read / Business)
  Future<List<ChatInboxModel>?> fetchChats({String? filter}) async {
    try {
      // Use new endpoint for live chat groups as per documentation
      final String endpoint = (filter == 'live_groups') ? AppUrls.liveChatGroups : AppUrls.chats;
      
      print("🔍 [LiveChatRepository] Fetching from: $endpoint with filter: $filter");
      
      Map<String, dynamic> queryParams = {};
      // Only add filter param if not using live-chat-groups endpoint
      if (filter != null && filter.isNotEmpty && filter != 'live_groups') {
        queryParams['filter'] = filter;
      }

      final response = await _api.callGet(endpoint, queryParams: queryParams, showErrorToast: false);

      print("📦 [LiveChatRepository] Full API Response: $response");

      if (response != null && response['status'] == true && response['data'] != null) {
        print("✅ [LiveChatRepository] Response status is true, data exists");
        print("📊 [LiveChatRepository] Data keys: ${response['data'].keys}");
        
        // Try multiple response structures
        List<ChatInboxModel>? parsedList;
        
        // Try 1: New structure with 'groups' array directly
        if (response['data']['groups'] != null) {
          print("✅ [LiveChatRepository] Found 'groups' key in data");
          final groupsData = response['data']['groups'];
          
          if (groupsData is List) {
            print("📊 [LiveChatRepository] groups is a List with ${groupsData.length} items");
            parsedList = groupsData
                .map((item) => ChatInboxModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          } else {
            print("⚠️ [LiveChatRepository] groups exists but is not a List, type: ${groupsData.runtimeType}");
          }
        }
        
        // Try 2: Old structure with 'chats' -> 'data'
        if (parsedList == null && response['data']['chats'] != null) {
          print("✅ [LiveChatRepository] Found 'chats' key in data");
          final chatsData = response['data']['chats'];
          
          if (chatsData['data'] != null && chatsData['data'] is List) {
            print("📊 [LiveChatRepository] chats.data is a List with ${chatsData['data'].length} items");
            final List<dynamic> rawList = chatsData['data'];
            parsedList = rawList
                .map((item) => ChatInboxModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          } else {
            print("⚠️ [LiveChatRepository] chats exists but chats.data is not valid");
          }
        }
        
        if (parsedList != null) {
          print("✅ [LiveChatRepository] Successfully parsed ${parsedList.length} items");
          return parsedList;
        } else {
          print("❌ [LiveChatRepository] Could not parse data with any known structure");
        }
      } else {
        print("❌ [LiveChatRepository] Invalid response: status=${response?['status']}, data exists=${response?['data'] != null}");
      }
    } catch (e, stackTrace) {
      print("❌ [LiveChatRepository] Error in fetchChats: $e");
      print("Stack trace: $stackTrace");
    }
    return null;
  }

  /// Fetch messages conversation history for a given chatId
  Future<List<ChatMessageModel>?> fetchMessages(int chatId) async {
    try {
      final response = await _api.callGet(AppUrls.chatMessages(chatId), showErrorToast: false);

      print("📦 [LiveChatRepository] fetchMessages response: $response");

      if (response != null && response['status'] == true && response['data'] != null) {
        final data = response['data'];
        
        // Handle nested structure: data -> messages -> data
        if (data['messages'] != null && data['messages']['data'] != null) {
          final List<dynamic> rawList = data['messages']['data'];
          print("✅ [LiveChatRepository] Found ${rawList.length} messages in nested structure");
          return rawList
              .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        // Handle direct array structure: data -> [array]
        else if (data is List) {
          print("✅ [LiveChatRepository] Found ${data.length} messages in direct array");
          return data
              .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else {
          print("❌ [LiveChatRepository] Unexpected data structure: ${data.runtimeType}");
        }
      }
    } catch (e, stackTrace) {
      print("❌ [LiveChatRepository] Error in fetchMessages: $e");
      print("Stack trace: $stackTrace");
    }
    return null;
  }

  /// Fetch details of a live chat group
  Future<LiveChatGroupModel?> fetchGroupDetails(dynamic chatId) async {
    try {
      final response = await _api.callGet(AppUrls.liveChatGroupDetail(chatId), showErrorToast: false);

      if (response != null && response['status'] == true && response['data'] != null) {
        final groupData = response['data']['group'];
        if (groupData != null) {
          return LiveChatGroupModel.fromJson(Map<String, dynamic>.from(groupData));
        }
      }
    } catch (e) {
      print("Error in LiveChatRepository.fetchGroupDetails: $e");
    }
    return null;
  }

  /// Send message (text, attachment files, or reply to message)
  Future<ChatMessageModel?> sendMessage(
    int chatId, {
    String? content,
    required String messageType,
    File? attachment,
    int? replyToId,
  }) async {
    try {
      final String endpoint = "api/v1/chats/$chatId/messages";
      
      Map<String, dynamic> bodyData = {
        "message_type": messageType,
      };
      
      if (content != null) {
        bodyData["content"] = content;
      }
      
      if (replyToId != null) {
        bodyData["reply_to_message_id"] = replyToId;
      }
      
      bool isMultipart = attachment != null;
      if (isMultipart) {
        bodyData["attachment"] = attachment;
      }

      final response = await _api.callPost(
        endpoint,
        data: bodyData,
        isFormData: isMultipart,
        showErrorToast: true,
      );

      if (response != null && response['status'] == true && response['data'] != null) {
        return ChatMessageModel.fromJson(response['data']);
      }
    } catch (e) {
      print("Error in LiveChatRepository.sendMessage: $e");
    }
    return null;
  }

  /// Mark messages as read for a given chatId and messageId
  Future<bool> markMessagesAsRead(int chatId, int lastReadMessageId) async {
    try {
      final String endpoint = "api/v1/chats/$chatId/read";
      final response = await _api.callPost(
        endpoint,
        data: {
          "last_read_message_id": lastReadMessageId,
        },
        showErrorToast: false,
      );
      return response != null && response['status'] == true;
    } catch (e) {
      print("Error in LiveChatRepository.markMessagesAsRead: $e");
    }
    return false;
  }

  /// Delete a message.
  /// [deleteForEveryone] = true  → sends { "delete_for_everyone": true }
  /// [deleteForEveryone] = false → sends { "delete_for_me": true }
  Future<bool> deleteMessage(int messageId, {bool deleteForEveryone = false}) async {
    try {
      final String endpoint = "api/v1/chats/messages/$messageId";
      final Map<String, dynamic> body = deleteForEveryone
          ? {"delete_for_everyone": true}
          : {"delete_for_me": true};

      final response = await _api.callDelete(endpoint, data: body);
      return response != null && response['status'] == true;
    } catch (e) {
      print("Error in LiveChatRepository.deleteMessage: $e");
    }
    return false;
  }
}

