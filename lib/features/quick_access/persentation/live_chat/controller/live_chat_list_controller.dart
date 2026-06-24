import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/chat_inbox_model.dart';
import '../repository/live_chat_repository.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR LIVE CHAT GROUPS LIST (CLEAN ARCHITECTURE)
// =========================================================================
class LiveChatListController extends GetxController {
  RxString searchQuery = "".obs;
  RxBool isLoading = false.obs;
  RxList<ChatInboxModel> groupsList = <ChatInboxModel>[].obs;
  RxList<ChatInboxModel> filteredGroups = <ChatInboxModel>[].obs;
  
  final searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final LiveChatRepository _repository = LiveChatRepository();

  // Fully accurate mock datasets with diverse states for fallback filtering
  final List<Map<String, dynamic>> mockGroupsJson = [
    {
      "id": 1,
      "name": "General Discussion",
      "description": "General chat for all active users",
      "chat_mode": "everyone",
      "participants_count": 142,
      "type": "group",
      "is_online": false,
      "is_admin": true,
      "unread_count": 3,
      "last_message": {
        "id": 1,
        "chat_id": 1,
        "content": "Hello everyone!",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-18T10:30:00Z",
        "sender": {"name": "John"}
      }
    },
    {
      "id": 2,
      "name": "Flutter Developers",
      "description": "Discuss Flutter & Dart developments",
      "chat_mode": "everyone",
      "participants_count": 86,
      "type": "group",
      "is_online": false,
      "is_admin": true,
      "unread_count": 2,
      "last_message": {
        "id": 2,
        "chat_id": 2,
        "content": "New package released!",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-27T09:45:00Z",
        "sender": {"name": "Emma"}
      }
    },
    {
      "id": 3,
      "name": "Announcements",
      "description": "Official admin announcements",
      "chat_mode": "admin_only",
      "participants_count": 55,
      "type": "business",
      "is_online": false,
      "is_admin": false,
      "unread_count": 0,
      "last_message": {
        "id": 3,
        "chat_id": 3,
        "content": "Maintenance on Sunday",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-26T14:30:00Z",
        "sender": {"name": "Admin"}
      }
    },
    {
      "id": 4,
      "name": "UI/UX Designers",
      "description": "Design trends & resource sharing room",
      "chat_mode": "everyone",
      "participants_count": 43,
      "type": "group",
      "is_online": false,
      "is_admin": true,
      "unread_count": 0,
      "last_message": {
        "id": 4,
        "chat_id": 4,
        "content": "Check this out",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-17T11:20:00Z",
        "sender": {"name": "Mike"}
      }
    },
    {
      "id": 5,
      "name": "Project Team",
      "description": "Internal project team sync",
      "chat_mode": "everyone",
      "participants_count": 10,
      "type": "group",
      "is_online": false,
      "is_admin": false,
      "unread_count": 0,
      "last_message": {
        "id": 5,
        "chat_id": 5,
        "content": "Thanks everyone!",
        "message_type": "text",
        "is_mine": true,
        "status": "sent",
        "created_at": "2026-05-15T14:10:00Z",
        "sender": {"name": "You"}
      }
    },
    {
      "id": 6,
      "name": "Business Hub",
      "description": "Corporate updates and hub meets",
      "chat_mode": "admin_only",
      "participants_count": 68,
      "type": "business",
      "is_online": false,
      "is_admin": false,
      "unread_count": 4,
      "last_message": {
        "id": 6,
        "chat_id": 6,
        "content": "Meeting at 4 PM",
        "message_type": "text",
        "is_mine": false,
        "status": "sent",
        "created_at": "2026-05-14T16:00:00Z",
        "sender": {"name": "Alex"}
      }
    }
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterList();
    });
    fetchGroups();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void changeTab(String tabName) {
    // Removed tab functionality - always use live_groups filter
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      // Always use 'live_groups' filter as per requirement
      final list = await _repository.fetchChats(filter: 'live_groups');

      if (list != null) {
        groupsList.assignAll(list);
        _filterList();
        return;
      }

      _loadMockGroups();
    } catch (e) {
      print("Fetch Groups Error: $e");
      _loadMockGroups();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadMockGroups() {
    final parsedMock = mockGroupsJson.map((e) => ChatInboxModel.fromJson(e)).toList();
    // Load all groups - no filtering needed since API filter handles it
    groupsList.assignAll(parsedMock);
    _filterList();
  }

  void _filterList() {
    var list = groupsList;

    var query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((g) {
        var name = g.name.toLowerCase();
        var desc = g.description.toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList().obs;
    }

    filteredGroups.assignAll(list);
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
