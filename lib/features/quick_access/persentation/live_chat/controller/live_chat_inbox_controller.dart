import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/network/websocket_service.dart';
import '../../../../../db/shared_pref_manager.dart';
import '../model/chat_inbox_model.dart';
import '../model/chat_message_model.dart';
import '../repository/live_chat_repository.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR CHATS INBOX (CLEAN ARCHITECTURE)
// =========================================================================
class LiveChatInboxController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ChatInboxModel> chatsList = <ChatInboxModel>[].obs;
  RxList<ChatInboxModel> filteredInbox = <ChatInboxModel>[].obs;

  RxString searchQuery = "".obs;
  final searchController = TextEditingController();
  
  final LiveChatRepository _repository = LiveChatRepository();

  String get _wsChannelName {
    final userId = SharedPrefManager().user?.id;
    return "private-user.$userId";
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterChats();
    });
    fetchChats();
    _initWebSocket();
  }

  @override
  void onClose() {
    _disposeWebSocket();
    searchController.dispose();
    super.onClose();
  }

  // =========================================================================
  // 🔌 WEBSOCKET: Real-time inbox updates via Laravel Reverb
  // =========================================================================

  Future<void> _initWebSocket() async {
    try {
      final wsService = Get.find<WebSocketService>();

      wsService.listen("message.sent", _onMessageSent);
      wsService.listen("message.read", _onMessageRead);

      await wsService.subscribe(_wsChannelName);
      print("🔌 [LiveChatInboxController] Subscribed to $_wsChannelName");
    } catch (e) {
      print("❌ [LiveChatInboxController] WebSocket init error: $e");
    }
  }

  void _disposeWebSocket() {
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.removeListener("message.sent", _onMessageSent);
      wsService.removeListener("message.read", _onMessageRead);
      wsService.unsubscribe(_wsChannelName);
      print("🔌 [LiveChatInboxController] Unsubscribed from $_wsChannelName");
    } catch (e) {
      print("⚠️ [LiveChatInboxController] WebSocket dispose error: $e");
    }
  }

  void _onMessageSent(dynamic data) {
    try {
      var parsedData = data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }
      
      final msg = ChatMessageModel.fromJson(Map<String, dynamic>.from(parsedData));
      
      final index = chatsList.indexWhere((c) => c.id == msg.chatId);
      if (index != -1) {
        final chat = chatsList[index];
        // Only increment unread count if we didn't send the message
        final newUnreadCount = msg.isMine ? chat.unreadCount : chat.unreadCount + 1;
        
        final updatedChat = ChatInboxModel(
          id: chat.id,
          uuid: chat.uuid,
          type: chat.type,
          name: chat.name,
          avatar: chat.avatar,
          participantsCount: chat.participantsCount,
          chatMode: chat.chatMode,
          isOnline: chat.isOnline,
          isAdmin: chat.isAdmin,
          unreadCount: newUnreadCount,
          lastMessage: msg,
          lastMessageAt: msg.createdAt ?? chat.lastMessageAt,
          description: chat.description,
        );

        // Remove old and insert at top
        chatsList.removeAt(index);
        chatsList.insert(0, updatedChat);
        filterChats();
      } else {
        // Chat doesn't exist in list? Might be a new group. Fetch chats again to get the group details
        fetchChats();
      }
    } catch (e) {
      print("Error in Inbox _onMessageSent: $e");
    }
  }

  void _onMessageRead(dynamic data) {
    try {
      var parsedData = data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }
      final chatId = parsedData['chat_id'];
      markChatAsReadLocally(chatId);
    } catch (e) {
      print("Error in Inbox _onMessageRead: $e");
    }
  }

  void markChatAsReadLocally(dynamic chatId) {
    final index = chatsList.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final chat = chatsList[index];
      if (chat.unreadCount > 0) {
        final updatedChat = ChatInboxModel(
          id: chat.id,
          uuid: chat.uuid,
          type: chat.type,
          name: chat.name,
          avatar: chat.avatar,
          participantsCount: chat.participantsCount,
          chatMode: chat.chatMode,
          isOnline: chat.isOnline,
          isAdmin: chat.isAdmin,
          unreadCount: 0,
          lastMessage: chat.lastMessage,
          lastMessageAt: chat.lastMessageAt,
          description: chat.description,
        );
        chatsList[index] = updatedChat;
        filterChats();
      }
    }
  }

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchChats(filter: "live_groups");

      if (list != null) {
        chatsList.assignAll(list);
        filterChats();
      }
    } catch (e) {
      print("Fetch Chats Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterChats() {
    var list = chatsList.toList();
    var query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((c) {
        var name = c.name.toLowerCase();
        var desc = c.description.toLowerCase();
        var msg = c.lastMessage?.content.toLowerCase() ?? "";
        return name.contains(query) || desc.contains(query) || msg.contains(query);
      }).toList();
    }
    filteredInbox.assignAll(list);
  }

  // =========================================================================
  // Helper Formatting Methods
  // =========================================================================

  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();

      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      if (isToday) {
        int hour = dt.hour;
        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) hour = 12;
        if (hour > 12) hour -= 12;
        String minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute $period';
      }

      final isYesterday = dt.year == now.year && dt.month == now.month && dt.day == now.day - 1;
      if (isYesterday) {
        return "Yesterday";
      }

      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return "";
    }
  }

  Color getAvatarColor(int chatId, String chatName) {
    List<Color> colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFEF4444), // Red
    ];
    int hash = 0;
    for (int i = 0; i < chatName.length; i++) {
      hash = chatName.codeUnitAt(i) + ((hash << 5) - hash);
    }
    int index = (hash.abs() + chatId) % colors.length;
    return colors[index];
  }
}
