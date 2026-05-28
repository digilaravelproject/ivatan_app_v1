import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/chat_inbox_model.dart';
import '../repository/live_chat_repository.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR CHATS INBOX (CLEAN ARCHITECTURE)
// =========================================================================
class LiveChatInboxController extends GetxController {
  RxString selectedTab = "Groups".obs;
  RxBool isLoading = false.obs;
  RxList<ChatInboxModel> chatsList = <ChatInboxModel>[].obs;
  RxList<ChatInboxModel> filteredInbox = <ChatInboxModel>[].obs;

  RxString searchQuery = "".obs;
  final searchController = TextEditingController();
  
  final LiveChatRepository _repository = LiveChatRepository();

  // Fully accurate mock chat inbox fallback list matching ChatInboxModel structure
  final List<Map<String, dynamic>> mockInboxChatsJson = [
    {
      "id": 15,
      "uuid": "abc-123-def",
      "type": "group",
      "name": "General Discussion",
      "participants_count": 142,
      "chat_mode": "everyone",
      "is_online": false,
      "is_admin": true,
      "unread_count": 3,
      "last_message": {
        "id": 100,
        "chat_id": 15,
        "content": "Hello everyone!",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-18T10:30:00Z",
        "sender": {"name": "John"}
      },
      "description": "General chat for all active users"
    },
    {
      "id": 16,
      "uuid": "xyz-789-uvw",
      "type": "group",
      "name": "Flutter Developers",
      "participants_count": 86,
      "chat_mode": "everyone",
      "is_online": false,
      "is_admin": true,
      "unread_count": 2,
      "last_message": {
        "id": 101,
        "chat_id": 16,
        "content": "New package released!",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-27T09:45:00Z",
        "sender": {"name": "Emma"}
      },
      "description": "Discuss Flutter & Dart developments"
    },
    {
      "id": 21,
      "uuid": "tuv-111-qqq",
      "type": "business",
      "name": "Tech News",
      "participants_count": 156,
      "chat_mode": "admin_only",
      "is_online": false,
      "is_admin": false,
      "unread_count": 1,
      "last_message": {
        "id": 102,
        "chat_id": 21,
        "content": "Interesting article",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-26T17:30:00Z",
        "sender": {"name": "Sara"}
      },
      "description": "Hot articles & global technology updates"
    },
    {
      "id": 18,
      "uuid": "mno-555-ppp",
      "type": "group",
      "name": "UI/UX Designers",
      "participants_count": 43,
      "chat_mode": "everyone",
      "is_online": false,
      "is_admin": true,
      "unread_count": 0,
      "last_message": {
        "id": 103,
        "chat_id": 18,
        "content": "Check this out",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-17T11:20:00Z",
        "sender": {"name": "Mike"}
      },
      "description": "Design trends & resource sharing room"
    },
    {
      "id": 19,
      "uuid": "def-444-rrr",
      "type": "group",
      "name": "Project Team",
      "participants_count": 10,
      "chat_mode": "everyone",
      "is_online": false,
      "is_admin": false,
      "unread_count": 0,
      "last_message": {
        "id": 104,
        "chat_id": 19,
        "content": "Thanks everyone!",
        "message_type": "text",
        "is_mine": true,
        "status": "sent",
        "created_at": "2026-05-15T14:10:00Z",
        "sender": {"name": "You"}
      },
      "description": "Internal project team sync"
    },
    {
      "id": 22,
      "uuid": "kkk-999-lll",
      "type": "business",
      "name": "Support Team",
      "participants_count": 2,
      "chat_mode": "everyone",
      "is_online": false,
      "is_admin": true,
      "unread_count": 0,
      "last_message": {
        "id": 105,
        "chat_id": 22,
        "content": "How can we help?",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-15T09:00:00Z",
        "sender": {"name": "Support"}
      },
      "description": "Customer care & service support feed"
    },
    {
      "id": 23,
      "uuid": "hhh-888-iii",
      "type": "business",
      "name": "Business Hub",
      "participants_count": 68,
      "chat_mode": "admin_only",
      "is_online": false,
      "is_admin": false,
      "unread_count": 0,
      "last_message": {
        "id": 106,
        "chat_id": 23,
        "content": "Meeting at 4 PM",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-14T16:00:00Z",
        "sender": {"name": "Alex"}
      },
      "description": "Corporate updates and hub meets"
    }
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterChats();
    });
    fetchChats();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(String tabName) {
    selectedTab.value = tabName;
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchChats(filter: selectedTab.value.toLowerCase());

      if (list != null) {
        chatsList.assignAll(list);
        filterChats();
        return;
      }

      _loadMockFilteredInbox();
    } catch (e) {
      print("Fetch Chats Error: $e");
      _loadMockFilteredInbox();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockFilteredInbox() {
    final parsedMock = mockInboxChatsJson.map((e) => ChatInboxModel.fromJson(e)).toList();
    var list = parsedMock;

    if (selectedTab.value == "Groups") {
      list = list.where((c) => c.type == "group").toList();
    } else if (selectedTab.value == "Unread") {
      list = list.where((c) => c.unreadCount > 0).toList();
    } else if (selectedTab.value == "Read") {
      list = list.where((c) => c.unreadCount == 0).toList();
    } else if (selectedTab.value == "Business") {
      list = list.where((c) => c.type == "business").toList();
    }

    chatsList.assignAll(list);
    filterChats();
  }

  void filterChats() {
    var list = chatsList;
    var query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((c) {
        var name = c.name.toLowerCase();
        var desc = c.description.toLowerCase();
        var msg = c.lastMessage?.content.toLowerCase() ?? "";
        return name.contains(query) || desc.contains(query) || msg.contains(query);
      }).toList().obs;
    }
    filteredInbox.assignAll(list);
  }

  Color getAvatarColor(int id, String name) {
    final colors = [
      const Color(0xFF0F9D58),
      const Color(0xFF673AB7),
      const Color(0xFF1E88E5),
      const Color(0xFFE91E63),
      const Color(0xFFFF9800),
      const Color(0xFF00BCD4),
      const Color(0xFFE53935),
    ];
    return colors[(id + name.length) % colors.length];
  }

  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      if (timeStr.contains("AM") || timeStr.contains("PM") || timeStr.toLowerCase() == "yesterday") {
        return timeStr;
      }
      final parsedDate = DateTime.parse(timeStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(parsedDate);
      
      if (difference.inDays == 0) {
        final hour = parsedDate.hour > 12 ? parsedDate.hour - 12 : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
        final minute = parsedDate.minute.toString().padLeft(2, '0');
        final ampm = parsedDate.hour >= 12 ? "PM" : "AM";
        return "$hour:$minute $ampm";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        return weekdays[parsedDate.weekday - 1];
      } else {
        final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return "${parsedDate.day} ${months[parsedDate.month - 1]}";
      }
    } catch (e) {
      return timeStr;
    }
  }
}
