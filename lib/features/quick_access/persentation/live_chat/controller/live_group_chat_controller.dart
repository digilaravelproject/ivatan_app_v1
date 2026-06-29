import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../core/network/websocket_service.dart';
import '../../../../../db/shared_pref_manager.dart';
import '../model/chat_inbox_model.dart';
import '../model/chat_message_model.dart';
import '../repository/live_chat_repository.dart';
import 'live_chat_inbox_controller.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR GROUP CONVERSATION FEED (CLEAN ARCHITECTURE)
// =========================================================================
class LiveGroupChatController extends GetxController {
  final int chatId;
  final String groupName;
  final Color avatarColor;
  final int participantsCount;
  final String chatMode;
  final bool isAdmin;
  final String description;

  LiveGroupChatController({
    required this.chatId,
    required this.groupName,
    required this.avatarColor,
    required this.participantsCount,
    required this.chatMode,
    required this.isAdmin,
    required this.description,
  });

  final messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxBool isSendingMessage = false.obs;
  RxBool isLoading = false.obs;
  RxBool isEmojiVisible = false.obs;

  // Active message we are currently replying to
  Rx<ChatMessageModel?> replyingToMessage = Rx<ChatMessageModel?>(null);

  // Pending attachment selected before sending
  Rx<File?> selectedAttachment = Rx<File?>(null);
  RxString selectedAttachmentType = "".obs;

  final LiveChatRepository _repository = LiveChatRepository();

  /// WebSocket channel name for this group chat
  String get _wsChannelName => "presence-presence-chat.$chatId";


  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isEmojiVisible.value = false;
      }
    });
    fetchMessages();
    _initWebSocket();
  }

  @override
  void onClose() {
    _disposeWebSocket();
    messageController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // =========================================================================
  // 🔌 WEBSOCKET: Real-time messaging via Laravel Reverb (WebSocketService)
  // =========================================================================

  /// Initialize WebSocket subscription & event listeners
  Future<void> _initWebSocket() async {
    try {
      final wsService = Get.find<WebSocketService>();

      // Register event listeners
      wsService.listen("message.sent", _onMessageSent);
      wsService.listen("message.edited", _onMessageEdited);
      wsService.listen("message.deleted", _onMessageDeleted);

      // Subscribe to the presence channel for this chat
      await wsService.subscribe(_wsChannelName);
      print("🔌 [LiveGroupChatController] Subscribed to $_wsChannelName via WebSocketService");
    } catch (e) {
      print("❌ [LiveGroupChatController] WebSocket init error: $e");
    }
  }

  /// Cleanup WebSocket listeners & unsubscribe on controller destroy
  void _disposeWebSocket() {
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.removeListener("message.sent", _onMessageSent);
      wsService.removeListener("message.edited", _onMessageEdited);
      wsService.removeListener("message.deleted", _onMessageDeleted);
      wsService.unsubscribe(_wsChannelName);
      print("🔌 [LiveGroupChatController] Unsubscribed from $_wsChannelName");
    } catch (e) {
      print("⚠️ [LiveGroupChatController] WebSocket dispose error: $e");
    }
  }

  /// Handle incoming real-time message
  void _onMessageSent(dynamic data) {
    try {
      print("🔥 [LiveGroupChatController] Received message.sent event: $data");
      var parsedData = data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }

      var newMessage = ChatMessageModel.fromJson(
        Map<String, dynamic>.from(parsedData),
      );

      // Check if this message was sent by the current user
      final currentUserId = SharedPrefManager().user?.id;
      if (newMessage.sender?.id != null && newMessage.sender?.id == currentUserId && !newMessage.isMine) {
        newMessage = ChatMessageModel(
          id: newMessage.id,
          chatId: newMessage.chatId,
          content: newMessage.content,
          messageType: newMessage.messageType,
          attachmentUrl: newMessage.attachmentUrl,
          meta: newMessage.meta,
          isMine: true,
          status: newMessage.status,
          createdAt: newMessage.createdAt,
          replyTo: newMessage.replyTo,
          repliedMessage: newMessage.repliedMessage,
          sender: newMessage.sender,
        );
      }

      // Only process messages belonging to THIS group chat
      if (newMessage.chatId != chatId) return;

      // Deduplicate: check if message already exists (API response or duplicate WS)
      final index = messages.indexWhere((m) => m.id == newMessage.id);
      if (index == -1) {
        // If it's from the current user, check if we have a pending optimistic message with the same content
        if (currentUserId != null && newMessage.sender?.id == currentUserId) {
          final pendingIndex = messages.indexWhere((m) => m.status == "sending" && m.content == newMessage.content);
          if (pendingIndex != -1) {
             // Match found! Update the optimistic message with the real server version seamlessly
             messages[pendingIndex] = newMessage;
             messages.refresh();
             return;
          }
        }
        // New message — insert at top (list is reversed)
        messages.insert(0, newMessage);
      } else {
        // Already exists (optimistic insert from sendMessage) — replace with server version
        messages[index] = newMessage;
      }
      messages.refresh();

      // Auto-mark as read since user is viewing this chat
      markAsRead();

      // Update inbox list last message
      _updateInboxLastMessage(parsedData);
    } catch (e) {
      print("❌ [LiveGroupChatController] Error parsing message.sent: $e");
    }
  }

  /// Handle real-time message edit
  void _onMessageEdited(dynamic data) {
    try {
      print("🔥 [LiveGroupChatController] Received message.edited event: $data");
      var parsedData = data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }

      final int msgChatId = parsedData["chat_id"] ?? 0;
      final int messageId = parsedData["message_id"] ?? 0;
      final String newContent = parsedData["new_content"] ?? "";

      // Only process for THIS chat
      if (msgChatId != chatId) return;

      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final oldMsg = messages[index];
        messages[index] = ChatMessageModel(
          id: oldMsg.id,
          chatId: oldMsg.chatId,
          content: newContent,
          messageType: oldMsg.messageType,
          attachmentUrl: oldMsg.attachmentUrl,
          meta: oldMsg.meta,
          isMine: oldMsg.isMine,
          status: oldMsg.status,
          createdAt: oldMsg.createdAt,
          replyTo: oldMsg.replyTo,
          repliedMessage: oldMsg.repliedMessage,
          sender: oldMsg.sender,
        );
        messages.refresh();
      }
    } catch (e) {
      print("❌ [LiveGroupChatController] Error parsing message.edited: $e");
    }
  }

  /// Handle real-time message deletion
  void _onMessageDeleted(dynamic data) {
    try {
      print("🔥 [LiveGroupChatController] Received message.deleted event: $data");
      var parsedData = data;
      if (parsedData is String) {
        parsedData = jsonDecode(parsedData);
      }

      final int msgChatId = parsedData["chat_id"] ?? 0;
      final int messageId = parsedData["message_id"] ?? 0;

      // Only process for THIS chat
      if (msgChatId != chatId) return;

      messages.removeWhere((m) => m.id == messageId);
      messages.refresh();
    } catch (e) {
      print("❌ [LiveGroupChatController] Error parsing message.deleted: $e");
    }
  }

  /// Update inbox list's last message when a new message arrives via WebSocket
  void _updateInboxLastMessage(dynamic parsedData) {
    try {
      if (Get.isRegistered<LiveChatInboxController>(tag: null)) {
        final inboxController = Get.find<LiveChatInboxController>();
        final int msgChatId = parsedData["chat_id"] ?? 0;

        // Update in main list
        final index = inboxController.chatsList.indexWhere((e) => e.id == msgChatId);
        if (index != -1) {
          final oldItem = inboxController.chatsList[index];
          final updatedLastMsg = ChatMessageModel.fromJson(
            Map<String, dynamic>.from(parsedData),
          );
          final updatedItem = ChatInboxModel(
            id: oldItem.id,
            uuid: oldItem.uuid,
            type: oldItem.type,
            name: oldItem.name,
            avatar: oldItem.avatar,
            isOnline: oldItem.isOnline,
            isAdmin: oldItem.isAdmin,
            unreadCount: oldItem.unreadCount,
            participantsCount: oldItem.participantsCount,
            chatMode: oldItem.chatMode,
            description: oldItem.description,
            lastMessage: updatedLastMsg,
            lastMessageAt: DateTime.now().toUtc().toIso8601String(),
          );

          // Move to top of list
          inboxController.chatsList.removeAt(index);
          inboxController.chatsList.insert(0, updatedItem);
          inboxController.chatsList.refresh();
          inboxController.filterChats();
        }
      }
    } catch (e) {
      print("⚠️ [LiveGroupChatController] Error updating inbox last message: $e");
    }
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchMessages(chatId);

      if (list != null) {
        messages.assignAll(list);
        markAsRead();
      }
      // If list is null or empty → messages stays [] (empty chat)
    } catch (e) {
      print("Fetch Messages Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead() async {
    if (messages.isEmpty) return;
    try {
      final lastMsg = messages.last;
      await _repository.markMessagesAsRead(chatId, lastMsg.id);
    } catch (e) {
      print("Error in LiveGroupChatController.markAsRead: $e");
    }
  }


  Future<void> sendMessage() async {
    var content = messageController.text.trim();
    final File? attachmentFile = selectedAttachment.value;
    final String attachmentType = selectedAttachmentType.value;

    if (content.isEmpty && attachmentFile == null) return;

    messageController.clear();
    // Reset selected attachment & reply view
    selectedAttachment.value = null;
    selectedAttachmentType.value = "";
    final int? replyId = replyingToMessage.value?.id;
    final ChatMessageModel? repliedMsg = replyingToMessage.value;
    replyingToMessage.value = null;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = ChatMessageModel(
      id: tempId,
      chatId: chatId,
      content: attachmentFile != null
          ? (content.isNotEmpty ? content : (attachmentType == "image" ? "Sending Image... 📷" : "Sending File... 📄"))
          : content,
      messageType: attachmentFile != null ? attachmentType : "text",
      attachmentUrl: attachmentFile?.path, // local file path for premium optimistic preview!
      isMine: true,
      status: "sending",
      createdAt: DateTime.now().toUtc().toIso8601String(),
      replyTo: replyId,
      repliedMessage: repliedMsg,
      sender: MessageSenderModel(name: "You"),
    );

    messages.insert(0, tempMsg);
    messages.refresh();

    ChatMessageModel? responseModel;
    if (attachmentFile != null) {
      responseModel = await _repository.sendMessage(
        chatId,
        content: content.isNotEmpty ? content : null,
        messageType: attachmentType,
        attachment: attachmentFile,
        replyToId: replyId,
      );
    } else {
      responseModel = await _repository.sendMessage(
        chatId,
        content: content,
        messageType: "text",
        replyToId: replyId,
      );
    }

    if (responseModel != null) {
      final serverMsg = responseModel; // local for null-safe promotion
      // The WebSocket message.sent event may have already inserted this message.
      // Check for both the temp ID and the real server ID to avoid duplicates.
      final tempIdx = messages.indexWhere((m) => m.id == tempId);
      final realIdx = messages.indexWhere((m) => m.id == serverMsg.id);

      if (tempIdx != -1 && realIdx != -1 && tempIdx != realIdx) {
        // Both exist — WebSocket delivered before API response. Update WS msg to ensure isMine is true, remove temp.
        messages[realIdx] = serverMsg;
        messages.removeAt(tempIdx);
      } else if (tempIdx != -1) {
        // Only temp exists — replace with real server response
        messages[tempIdx] = serverMsg;
      } else if (realIdx != -1) {
        // Only WS msg exists — update it to ensure isMine is true
        messages[realIdx] = serverMsg;
      } else {
        // Neither exists (rare) — insert
        messages.insert(0, serverMsg);
      }
    } else {
      // API failed — remove optimistic temp message
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages.removeAt(idx);
      }
    }
    messages.refresh();
  }

  Future<void> pickAttachment(String fileType) async {
    File? selectedFile;
    String type = "text";

    try {
      if (fileType == "image" || fileType == "camera") {
        final picker = ImagePicker();
        final pickedXFile = await picker.pickImage(
          source: fileType == "camera" ? ImageSource.camera : ImageSource.gallery,
        );
        if (pickedXFile != null) {
          selectedFile = File(pickedXFile.path);
          type = "image";
        }
      } else if (fileType == "document" || fileType == "file") {
        final result = await FilePicker.platform.pickFiles(type: FileType.any);
        if (result != null && result.files.single.path != null) {
          selectedFile = File(result.files.single.path!);
          type = "file";
        }
      }
    } catch (e) {
      print("Pick Attachment Error: $e");
      return;
    }

    if (selectedFile == null) return;

    selectedAttachment.value = selectedFile;
    selectedAttachmentType.value = type;
    focusNode.requestFocus(); // Auto focus text field for caption!
  }

  Future<void> deleteMessage(int id, {bool deleteForEveryone = false}) async {
    // Optimistic: remove from UI immediately
    final removedMsg = messages.firstWhereOrNull((m) => m.id == id);
    messages.removeWhere((m) => m.id == id);
    messages.refresh();

    final success = await _repository.deleteMessage(id, deleteForEveryone: deleteForEveryone);

    if (!success && removedMsg != null) {
      // Rollback if API failed
      messages.insert(0, removedMsg);
      messages.sort((a, b) => b.id.compareTo(a.id));
      messages.refresh();
    }
  }


  Color getSenderColor(String name) {
    final colors = [
      const Color(0xFF0F9D58),
      const Color(0xFF673AB7),
      const Color(0xFF1E88E5),
      const Color(0xFFE91E63),
      const Color(0xFFFF9800),
      const Color(0xFF00BCD4),
    ];
    return colors[name.length % colors.length];
  }

  String formatMessageTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(timeStr).toLocal();
      final hour = parsedDate.hour > 12 ? parsedDate.hour - 12 : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
      final minute = parsedDate.minute.toString().padLeft(2, '0');
      final ampm = parsedDate.hour >= 12 ? "PM" : "AM";
      return "$hour:$minute $ampm";
    } catch (e) {
      return timeStr;
    }
  }

  String formatMessageDate(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(timeStr).toLocal();
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${parsedDate.day} ${months[parsedDate.month - 1]}, ${parsedDate.year}";
    } catch (e) {
      return timeStr;
    }
  }
}
