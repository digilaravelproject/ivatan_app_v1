import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../../core/network/api_services.dart';
import '../model/chat_data_model.dart';
import '../model/individualChatModel.dart';


/*
class ChatMessagesController extends GetxController {
  final ApiServices api = Get.find<ApiServices>();
  RxBool isLoading = false.obs;
  RxBool isMoreLoading = false.obs;
  RxBool isSendingMessage = false.obs;
  RxBool isProfileLoading = true.obs;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  String? nextCursor;
  bool hasMore = true;

  var chatProfile = Rxn<ChatListModel>();

  final messageController = TextEditingController();

  // late PusherClient _pusher;
  // Channel? _channel;
  late PusherChannelsFlutter pusher;


  Future<void> initPusher() async {
    final chatId = chatProfile.value?.id;
    if (chatId == null) return;

    await pusher.init(
      apiKey: "1c97cfa884ecb61e0959",
      cluster: "ap2",
      authEndpoint: "[https://ivatan.in/api/broadcasting/auth](https://www.ivatan.in/api/v1/chats/$chatId/messages)",
      onEvent: (event) {
        if (event.eventName == "message.sent") {
          final data = jsonDecode(event.data);
          final newMessage = ChatMessage.fromJson(data);

          if (!messages.any((m) => m.id == newMessage.id)) {
            messages.add(newMessage);
          }
        }
      },
    );

    await pusher.subscribe(channelName: "private-chat-$chatId");
    await pusher.connect();
  }


  @override
  void onInit() {
    _getData();
    super.onInit();
  }

  Future<void> fetchMessages(int chatId, {bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMore) return;
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
        messages.clear();
        nextCursor = null;
        hasMore = true;
      }

      final response = await api.callGet(
        "api/v1/chats/$chatId/messages",
        queryParams: nextCursor != null ? {"cursor": nextCursor} : null,
      );

      print("chattmessage : " + response.toString());

      if (response != null &&
          response["status"] == true &&
          response['data'] is List) {
        var apiList = response['data'] as List;
        messages.assignAll(apiList.map((e) => ChatMessage.fromJson(e)));
      }
    } catch (e, stk) {
      print("fetchMessages error: $e,\n$stk");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  // Future<void> _getData() async {
  //   if (Get.arguments is ChatListModel) {
  //     chatProfile.value = Get.arguments as ChatListModel;
  //     var r = chatProfile.value;
  //     if (r != null) {
  //       await fetchMessages(r.id.toInt());
  //       readMessage(messages.last.id.toString());
  //     }
  //   }
  // }


  Future<void> _getData() async {
    isProfileLoading.value = true;

    try {
      var args = Get.arguments;

      if (args is ChatListModel) {
        chatProfile.value = args;
        await fetchMessages(args.id);
      }
      else if (args is String || args is int) {
        int chatId = int.parse(args.toString());

        final response = await api.callGet("api/v1/chats/$chatId");

        if (response != null && response["status"] == true) {
          chatProfile.value = ChatListModel.fromJson(response["data"]);
          await fetchMessages(chatId);
          await initPusher();
        }
      }

      // if (chatProfile.value != null) {
      //   await initPusher(); // 🔥 IMPORTANT
      // }


      if (messages.isNotEmpty) {
        await readMessage(messages.last.id.toString());
      }
    } catch (e) {
      print("error = $e");
    } finally {
      isProfileLoading.value = false;
    }
  }

  @override
  void onClose() {
    pusher.unsubscribe(channelName: "private-chat-${chatProfile.value?.id}");
    pusher.disconnect();
    messageController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    try {
      isSendingMessage.value = true;
      var p = chatProfile.value;
      var m = messageController.text;
      if (p == null) {
        return;
      }
      if (m.isEmpty) {
        CustomSnackBar.showError(message: "Message can't be empty");
        return;
      }
      final response = await api.callPost(
        "api/v1/chats/${p.id}/messages",
        data: {"content": m, "message_type": "text"},
      );
      log("sendMessage : " + response.toString());
      if (response == null) {
        return;
      }
      if (response["status"] == true) {
        messages.add(ChatMessage.fromJson(response['data']));
        messageController.clear();
      }
      if (response.containsKey("Message")) {
        CustomSnackBar.showSuccess(message: response['Message'].toString());
      }
    } catch (e, stk) {
      print("fetchMessages error: $e,\n$stk");
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> readMessage(String messageID) async {
    try {
      var p = chatProfile.value;
      if (p == null) {
        return;
      }
      final response = await api.callPost(
        "api/v1/chats/${p.id}/read",
        data: {"last_read_message_id": messageID},
        isFormData: true,
      );
      log("readMessage : " + response.toString());
      if (response == null) {
        return;
      }
      if (response["status"] == true) {
        messages.add(ChatMessage.fromJson(response['data']));
        messageController.clear();
      }
      if (response.containsKey("Message")) {
        CustomSnackBar.showSuccess(message: response['Message'].toString());
      }
    } catch (e, stk) {
      print("readMessage error: $e,\n$stk");
    }
  }

  Future<void> deleteMessage(
    String messageID, {
    bool deleteForEveryOne = false,
  }) async {
    try {
      final response = await api.callDelete(
        "api/v1/chats/messages/$messageID",
        data: {"delete_for_everyone": deleteForEveryOne},
      );

      log("deleteMessage response: $response");

      if (response == null) return;

      if (response["status"] == true) {
        messages.removeWhere((msg) => msg.id.toString() == messageID);
        messageController.clear();
      }

      if (response.containsKey("Message")) {
        CustomSnackBar.showSuccess(message: response["Message"].toString());
      }
    } catch (e, stk) {
      print("deleteMessage error: $e,\n$stk");
    }
  }
}
*/




/*class ChatMessagesController extends GetxController {
  // Dependency Injection for API Services
  final ApiServices api = Get.find<ApiServices>();

  // Storage instance to retrieve User Token
 // final GetStorage _storage = GetStorage();

  // Observable States for UI
  RxBool isLoading = false.obs;
  RxBool isMoreLoading = false.obs;
  RxBool isSendingMessage = false.obs;
  RxBool isProfileLoading = true.obs;

  // Main Messages List
  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  String? nextCursor;
  bool hasMore = true;

  var chatProfile = Rxn<ChatListModel>();
  final messageController = TextEditingController();

  // Pusher Instance
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  /// =========================================================================
  /// 🔐 HELPER: Retrieve Auth Token Automatically
  /// =========================================================================
  /// This function tries to get the token from local storage.
  /// It handles cases where the token might be missing.
  Future<String> _getAuthToken() async {
    try {
      // Attempt to read 'token' from GetStorage
      // 'token' is the standard key. If you use 'access_token', change it here.
      String? token = SharedPrefManager().token;

      if (token != null && token.isNotEmpty) {
        return token;
      }

      log("⚠️ Warning: Token not found in storage.");
      return "";
    } catch (e) {
      log("❌ Error retrieving token: $e");
      return "";
    }
  }

  /// =========================================================================
  /// 🔥 CORE: Initialize Real-time Pusher Connection
  /// =========================================================================
  Future<void> initPusher() async {
    final chatId = chatProfile.value?.id;
    if (chatId == null) return;

    // 1. Get Token for Private Channel Auth
    String userToken = await _getAuthToken();

    // 2. Guard Clause: If no token, we can't connect to private channels
    if (userToken.isEmpty) {
      log("🔴 Aborting Pusher: Authentication Token is missing.");
      return;
    }

    try {
      // 3. Cleanup: Unsubscribe/Disconnect previous sessions to prevent conflicts
      try {
        await pusher.unsubscribe(channelName: "private-chat.$chatId");
      } catch (_) {} // Ignore cleanup errors

      // 4. Initialize Pusher with Auth Logic
      await pusher.init(
          apiKey: "1c97cfa884ecb61e0959",
          cluster: "ap2",

          // --- AUTHENTICATION HANDLER ---
          // This is called automatically when subscribing to 'private-' channels
          onAuthorizer: (String channelName, String socketId, options) async {
            log("🔐 Authenticating channel: $channelName");
            return {
              "authEndpoint": "https://ivatan.in/api/broadcasting/auth",
              "headers": {
                "Authorization": "Bearer $userToken", // Injecting the real token
                "Content-Type": "application/json"
              }
            };
          },

          // --- EVENT LISTENER ---
          // Handles all incoming real-time events
          onEvent: (event) {
            log("⚡ Event Received: ${event.eventName} | Channel: ${event.channelName}");

            // We only care about 'message.sent' events
            if (event.eventName == "message.sent") {
              _handleNewMessageEvent(event.data);
            }
          },

          // --- CONNECTION STATUS LOGGING ---
          onConnectionStateChange: (currentState, previousState) {
            log("🔌 Pusher Connection: $currentState");
          },

          onError: (message, code, error) {
            log("❌ Pusher Error: $message (Code: $code)");
          }
      );

      // 5. Connect and Subscribe
      String channelName = "private-chat.$chatId";
      log("📡 Subscribing to: $channelName");

      await pusher.connect();
      await pusher.subscribe(channelName: channelName);

    } catch (e, stack) {
      log("💥 Critical Pusher Init Error: $e\n$stack");
    }
  }

  /// =========================================================================
  /// 📩 HELPER: Process Incoming Real-time Message
  /// =========================================================================
  void _handleNewMessageEvent(dynamic rawData) {
    try {
      var data = rawData;
      // If data comes as a JSON String, decode it first
      if (data is String) {
        data = jsonDecode(data);
      }

      final newMessage = ChatMessage.fromJson(data);

      // Prevent Duplicates: Check if message ID already exists in the list
      int index = messages.indexWhere((m) => m.id == newMessage.id);

      if (index == -1) {
        // It's a new message: Insert at the TOP of the list
        messages.insert(0, newMessage);

        // Force UI refresh to ensure the new bubble appears instantly
        messages.refresh();
        log("✅ UI Updated: New real-time message added.");
      } else {
        // Message exists (maybe an update): Replace it
        messages[index] = newMessage;
        messages.refresh();
      }
    } catch (e) {
      log("❌ Failed to parse real-time message: $e");
    }
  }

  /// =========================================================================
  /// 🔄 LIFECYCLE METHODS
  /// =========================================================================
  @override
  void onInit() {
    super.onInit();
    _getData();
  }

  @override
  void onClose() {
    // Clean up Pusher connection when controller is destroyed (Back press)
    if (chatProfile.value != null) {
      pusher.unsubscribe(channelName: "private-chat.${chatProfile.value!.id}");
    }
    pusher.disconnect();
    messageController.dispose();
    super.onClose();
  }

  /// =========================================================================
  /// 🌐 API: Fetch Initial Messages
  /// =========================================================================
  Future<void> fetchMessages(int chatId, {bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMore) return;
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
        messages.clear();
        nextCursor = null;
        hasMore = true;
      }

      final response = await api.callGet(
        "api/v1/chats/$chatId/messages",
        queryParams: nextCursor != null ? {"cursor": nextCursor} : null,
      );

      if (response != null && response["status"] == true && response['data'] is List) {
        var apiList = response['data'] as List;
        List<ChatMessage> fetchedMessages = apiList.map((e) => ChatMessage.fromJson(e)).toList();

        // Assign fetched messages to the list
        messages.assignAll(fetchedMessages);
      }
    } catch (e, stk) {
      log("❌ fetchMessages Error: $e,\n$stk");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  /// =========================================================================
  /// 🏁 SETUP: Initial Data Loading
  /// =========================================================================
  Future<void> _getData() async {
    isProfileLoading.value = true;
    try {
      var args = Get.arguments;

      if (args is ChatListModel) {
        chatProfile.value = args;
        await fetchMessages(args.id);
      } else if (args is String || args is int) {
        int chatId = int.parse(args.toString());
        final response = await api.callGet("api/v1/chats/$chatId");

        if (response != null && response["status"] == true) {
          chatProfile.value = ChatListModel.fromJson(response["data"]);
          await fetchMessages(chatId);
        }
      }

      // Initialize Pusher only AFTER we have valid chat details
      if (chatProfile.value != null) {
        await initPusher();
      }

      // Mark latest message as read if applicable
      if (messages.isNotEmpty && chatProfile.value != null) {
        readMessage(messages.last.id.toString());
      }
    } catch (e) {
      log("❌ Setup Error: $e");
    } finally {
      isProfileLoading.value = false;
    }
  }

  /// =========================================================================
  /// 📤 ACTION: Send Message
  /// =========================================================================
  Future<void> sendMessage() async {
    try {
      isSendingMessage.value = true;
      var p = chatProfile.value;
      var m = messageController.text;

      if (p == null) return;
      if (m.isEmpty) {
        CustomSnackBar.showError(message: "Message can't be empty");
        return;
      }

      final response = await api.callPost(
        "api/v1/chats/${p.id}/messages",
        data: {"content": m, "message_type": "text"},
      );

      if (response != null && response["status"] == true) {
        final newMsg = ChatMessage.fromJson(response['data']);

        // Optimistic Update: Add to list immediately to feel fast
        if (!messages.any((element) => element.id == newMsg.id)) {
          messages.insert(0, newMsg);
          messageController.clear();
        }
      }
    } catch (e, stk) {
      log("❌ sendMessage Error: $e\n$stk");
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// =========================================================================
  /// 👀 ACTION: Mark Message as Read
  /// =========================================================================
  Future<void> readMessage(String messageID) async {
    try {
      var p = chatProfile.value;
      if (p == null) return;
      await api.callPost(
        "api/v1/chats/${p.id}/read",
        data: {"last_read_message_id": messageID},
        isFormData: true,
      );
    } catch (e) {
      log("❌ readMessage Error: $e");
    }
  }

  /// =========================================================================
  /// 🗑️ ACTION: Delete Message
  /// =========================================================================
  Future<void> deleteMessage(String messageID, {bool deleteForEveryOne = false}) async {
    try {
      final response = await api.callDelete(
        "api/v1/chats/messages/$messageID",
        data: {"delete_for_everyone": deleteForEveryOne},
      );
      if (response != null && response["status"] == true) {
        messages.removeWhere((msg) => msg.id.toString() == messageID);
      }
    } catch (e) {
      log("❌ deleteMessage Error: $e");
    }
  }
}*/


class ChatMessagesController extends GetxController {
  final ApiServices api = Get.find<ApiServices>();

  RxBool isLoading = false.obs;
  RxBool isMoreLoading = false.obs;
  RxBool isSendingMessage = false.obs;
  RxBool isProfileLoading = true.obs;

  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  String? nextCursor;
  bool hasMore = true;

  var chatProfile = Rxn<ChatListModel>();
  final messageController = TextEditingController();
  
  // Emoji & Focus
  final FocusNode focusNode = FocusNode();
  RxBool isEmojiVisible = false.obs;

  // Pusher Instance
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  /// 🔥 1. Initialize Pusher & Subscribe
  Future<void> initPusher() async {
    final chatId = chatProfile.value?.id;
    if (chatId == null) return;

    // TODO: 🔴 GET USER TOKEN HERE (Required for Private Channel)
    // You must retrieve the Bearer token from your storage (GetStorage/SharedPreferences)
    // String userToken = Get.find<StorageService>().getToken();
    String userToken = SharedPrefManager().token.toString(); // <--- INSERT YOUR TOKEN RETRIEVAL LOGIC HERE

    if (userToken.isEmpty) {
      print("⚠️ Pusher Warning: User Token is empty. Auth may fail.");
    }

    try {
      await pusher.init(
          apiKey: "1c97cfa884ecb61e0959",
          cluster: "ap2",
          // ✅ AUTHENTICATION LOGIC
          onAuthorizer: (String channelName, String socketId, options) async {
            return {
              "authEndpoint": "https://ivatan.in/api/broadcasting/auth",
              "headers": {
                "Authorization": "Bearer $userToken",
                "Content-Type": "application/json"
              }
            };
          },
          // ✅ EVENT LISTENER
          onEvent: (event) {
            log("🔥 Pusher Event: ${event.eventName}");

            if (event.eventName == "message.sent") {
              // 1. Parse Data
              var data = event.data;
              if (data is String) {
                data = jsonDecode(data);
              }

              // 2. Convert to Model
              final newMessage = ChatMessage.fromJson(data);


              if (!messages.any((m) => m.id == newMessage.id)) {
                messages.add(newMessage);

                // Optional: Scroll to bottom logic here if needed
              }
            }
          },
          onConnectionStateChange: (currentState, previousState) {
            print("🔌 Pusher Connection: $currentState");
          },
          onError: (message, code, error) {
            print("❌ Pusher Error: $message Code: $code");
          }
      );


      await pusher.subscribe(channelName: "private-chat.$chatId");
      await pusher.connect();

    } catch (e) {
      print("Pusher Init Error: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isEmojiVisible.value = false;
      }
    });
    _getData();
  }

  Future<void> fetchMessages(int chatId, {bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMore) return;
        isMoreLoading.value = true;
      } else {
        isLoading.value = true;
        messages.clear();
        nextCursor = null;
        hasMore = true;
      }

      final response = await api.callGet(
        "api/v1/chats/$chatId/messages",
        queryParams: nextCursor != null ? {"cursor": nextCursor} : null,
      );

      print("fetchMessages response: $response");

      if (response != null && response["status"] == true && response['data'] is List) {
        var apiList = response['data'] as List;
        List<ChatMessage> fetchedMessages = apiList.map((e) => ChatMessage.fromJson(e)).toList();

        // Laravel usually returns 'latest' (newest first).
        // We reverse it so oldest is at top, new messages append at bottom.
        messages.assignAll(fetchedMessages.reversed.toList());
      }
    } catch (e, stk) {
      print("fetchMessages error: $e,\n$stk");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> _getData() async {
    isProfileLoading.value = true;
    try {
      var args = Get.arguments;

      if (args is ChatListModel) {
        chatProfile.value = args;
        await fetchMessages(args.id);
      } else if (args is String || args is int) {
        int chatId = int.parse(args.toString());
        final response = await api.callGet("api/v1/chats/$chatId");

        if (response != null && response["status"] == true) {
          chatProfile.value = ChatListModel.fromJson(response["data"]);
          await fetchMessages(chatId);
        }
      }

      // ✅ Init Pusher AFTER data is loaded
      if (chatProfile.value != null) {
        await initPusher();
      }

      if (messages.isNotEmpty) {
        // Safe check for null
        if(chatProfile.value != null) {
          readMessage(messages.last.id.toString());
        }
      }
    } catch (e) {
      print("error = $e");
    } finally {
      isProfileLoading.value = false;
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    if (chatProfile.value != null) {
      pusher.unsubscribe(channelName: "private-chat.${chatProfile.value!.id}");
    }
    pusher.disconnect();
    messageController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    try {
      isSendingMessage.value = true;
      var p = chatProfile.value;
      var m = messageController.text;
      if (p == null) return;
      if (m.isEmpty) {
        CustomSnackBar.showError(message: "Message can't be empty");
        return;
      }
      final response = await api.callPost(
        "api/v1/chats/${p.id}/messages",
        data: {"content": m, "message_type": "text"},
      );

      log("sendMessage : " + response.toString());

      if (response != null && response["status"] == true) {
        // Add sent message locally immediately
        messages.add(ChatMessage.fromJson(response['data']));
        messageController.clear();
      }
    } catch (e, stk) {
      print("sendMessage error: $e,\n$stk");
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> sendFile(File file, String messageType) async {
    try {
      isSendingMessage.value = true;
      var p = chatProfile.value;
      if (p == null) return;

      String fileName = file.path.split('/').last;
      
      // Prepare FormData
      // distinct for file upload vs text
      Map<String, dynamic> data = {
        "message_type": messageType,
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      };

      final response = await api.callPost(
        "api/v1/chats/${p.id}/messages",
        data: data,
        isFormData: true,
      );

      log("sendFile response: $response");

      if (response != null && response["status"] == true) {
        messages.add(ChatMessage.fromJson(response['data']));
      } else {
         CustomSnackBar.showError(message: response?['message'] ?? "Failed to send file");
      }
    } catch (e, stk) {
      print("sendFile error: $e,\n$stk");
      CustomSnackBar.showError(message: "Error sending file");
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> readMessage(String messageID) async {
    try {
      var p = chatProfile.value;
      if (p == null) return;

      final response = await api.callPost(
        "api/v1/chats/${p.id}/read",
        data: {"last_read_message_id": messageID},
        isFormData: true,
      );
      // Logic for read receipts if needed
    } catch (e) {
      print("readMessage error: $e");
    }
  }

  Future<void> deleteMessage(String messageID, {bool deleteForEveryOne = false}) async {
    try {
      final response = await api.callDelete(
        "api/v1/chats/messages/$messageID",
        data: {"delete_for_everyone": deleteForEveryOne},
      );

      if (response != null && response["status"] == true) {
        messages.removeWhere((msg) => msg.id.toString() == messageID);
      }
    } catch (e) {
      print("deleteMessage error: $e");
    }
  }
}
