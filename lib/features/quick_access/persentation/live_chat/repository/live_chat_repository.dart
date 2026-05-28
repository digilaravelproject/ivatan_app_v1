import 'dart:io';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../model/chat_inbox_model.dart';
import '../model/chat_message_model.dart';

// =========================================================================
// 🚀 DEDICATED REPOSITORY PATTERN LAYER FOR LIVE CHAT ENDPOINTS
// =========================================================================
class LiveChatRepository {
  final ApiServices _api = Get.put(ApiServices());

  /// Fetch chats listing (Groups / Unread / Read / Business)
  Future<List<ChatInboxModel>?> fetchChats({String? filter}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await _api.callGet(AppUrls.chats, queryParams: queryParams, showErrorToast: false);

      if (response != null && response['status'] == true && response['data'] != null) {
        final chatsData = response['data']['chats'];
        if (chatsData != null && chatsData['data'] != null) {
          final List<dynamic> rawList = chatsData['data'];
          return rawList
              .map((item) => ChatInboxModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      print("Error in LiveChatRepository.fetchChats: $e");
    }
    return null;
  }

  /// Fetch messages conversation history for a given chatId
  Future<List<ChatMessageModel>?> fetchMessages(int chatId) async {
    try {
      final response = await _api.callGet(AppUrls.chatMessages(chatId), showErrorToast: false);

      if (response != null && response['status'] == true && response['data'] != null) {
        final List<dynamic> rawList = response['data'];
        return rawList
            .map((item) => ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      print("Error in LiveChatRepository.fetchMessages: $e");
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

