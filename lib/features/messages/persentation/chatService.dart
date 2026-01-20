/*import 'dart:convert';
import 'package:get/get.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';
import '../controller/chat_message_controller.dart';
import '../model/individualChatModel.dart';


import 'dart:convert';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';


class ChatService {
  late PusherClient _pusher;
  late Channel _channel;

  /// Initialize Pusher
  Future<void> initPusher(int chatId, ChatMessagesController controller) async {
    try {
      // Create Pusher options
      PusherOptions options = PusherOptions(
        cluster: 'ap2',
        encrypted: true,
        // For private/auth channels, provide auth endpoint if needed
        auth: PusherAuth(
          'https://yourbackend.com/broadcasting/auth', // replace with your auth endpoint
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        ),
      );

      // Initialize Pusher client
      _pusher = PusherClient(
        '1c97cfa884ecb61e0959', // your apiKey
        options,
        autoConnect: false,
        enableLogging: true, // optional, for debug
      );

      // Connect Pusher
      _pusher.connect();

      // Subscribe to private chat channel
      _channel = _pusher.subscribe('private-chat-$chatId');

      // Bind to 'new-message' event
      _channel.bind('new-message', (PusherEvent? event) {
        if (event?.data != null) {
          final msg = ChatMessage.fromJson(jsonDecode(event!.data!));
          controller.messages.add(msg); // Add to RxList
        }
      });

      // Optionally listen to connection state changes
      _pusher.connection.bind('state_change', (state) {
        print('Connection State: ${state?.currentState}');
      });

      _pusher.connection.bind('error', (error) {
        print('Pusher Error: $error');
      });

    } catch (e) {
      print('Pusher init error: $e');
    }
  }

  /// Disconnect
  void disconnect() {
    _channel.unbind('new-message');
    _pusher.unsubscribe('private-chat');
    _pusher.disconnect();
  }
}*/
