import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../model/chat_message_model.dart';
import '../repository/live_chat_repository.dart';

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

  // Active message we are currently replying to
  Rx<ChatMessageModel?> replyingToMessage = Rx<ChatMessageModel?>(null);

  // Pending attachment selected before sending
  Rx<File?> selectedAttachment = Rx<File?>(null);
  RxString selectedAttachmentType = "".obs;

  final LiveChatRepository _repository = LiveChatRepository();


  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final list = await _repository.fetchMessages(chatId);

      if (list != null) {
        messages.assignAll(list.reversed.toList());
        _scrollToBottom(delayMs: 200);
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

    messages.add(tempMsg);
    messages.refresh();
    _scrollToBottom();

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
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages[idx] = responseModel;
      } else {
        messages.add(responseModel);
      }
    } else {
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages.removeAt(idx);
      }
    }
    messages.refresh();
    _scrollToBottom();
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
      messages.add(removedMsg);
      messages.sort((a, b) => a.id.compareTo(b.id));
      messages.refresh();
    }
  }

  void _scrollToBottom({int delayMs = 100}) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
