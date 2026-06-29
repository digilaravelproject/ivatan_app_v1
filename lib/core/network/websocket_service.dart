import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';

class WebSocketService extends GetxService {
  WebSocket? _socket;
  Timer? _heartbeatTimer;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _socketId;
  final String _appKey = "cvtm70sqh0nz9ogq1cza"; // Default app key for Reverb

  // Track active subscriptions to resubscribe on reconnection
  final Set<String> _activeChannels = {};

  // Listeners map
  final Map<String, List<Function(dynamic)>> _eventListeners = {};

  // Status getters
  bool get isConnected => _isConnected;
  String? get socketId => _socketId;

  int _connectionAttempt = 0;

  /// Get candidate WebSocket URLs based on environment
  List<String> get _wsUrls {
    final String base = AppUrls.baseUrl;
    if (base.contains("127.0.0.1") || base.contains("localhost")) {
      return ["ws://127.0.0.1:8080/app/$_appKey?protocol=7&client=js&version=7.0.3&flash=false"];
    }

    final Uri parsedBase = Uri.parse(base);
    final String baseHost = parsedBase.host;
    
    // Fallback domains
    String alternateHost = "socket.ivatan.in";
    if (baseHost.contains("ivatan.in")) {
      alternateHost = "socket.ivatan.in";
    } else if (baseHost.isNotEmpty) {
      alternateHost = "socket.$baseHost".replaceAll("www.", "");
    }

    return [
      "wss://$baseHost/app/$_appKey?protocol=7&client=js&version=7.0.3&flash=false",
      "wss://socket.ivatan.com/app/$_appKey?protocol=7&client=js&version=7.0.3&flash=false",
      "wss://$alternateHost/app/$_appKey?protocol=7&client=js&version=7.0.3&flash=false",
    ];
  }

  /// Get the broadcasting auth endpoint URL
  String get _authUrl {
    String base = AppUrls.baseUrl;
    if (!base.endsWith("/")) {
      base += "/";
    }
    return "${base}api/broadcasting/auth";
  }

  /// Initializes and connects to the WebSocket if user is logged in
  Future<WebSocketService> init() async {
    dev.log("🔌 [WebSocketService] Initializing WebSocket Service...", name: "WebSocket");
    if (SharedPrefManager().isUserLogin) {
      connect();
    } else {
      dev.log("🔌 [WebSocketService] User is not logged in. Skipping connection.", name: "WebSocket");
    }
    return this;
  }

  /// Connects to the Laravel Reverb WebSocket Server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    final String token = SharedPrefManager().token ?? "";
    if (token.isEmpty) {
      dev.log("⚠️ [WebSocketService] Cannot connect: Bearer token is empty.", name: "WebSocket");
      return;
    }

    _isConnecting = true;
    final urls = _wsUrls;
    final String url = urls[_connectionAttempt % urls.length];
    
    print("🔌 [WebSocketService] Connecting to WebSocket (Attempt ${_connectionAttempt + 1}): $url");
    dev.log("🔌 [WebSocketService] Connecting to WebSocket: $url", name: "WebSocket");

    try {
      _socket = await WebSocket.connect(url).timeout(const Duration(seconds: 10));
      _isConnected = true;
      _isConnecting = false;
      _connectionAttempt = 0; // Reset on success
      print("✅ [WebSocketService] WebSocket connected successfully!");
      dev.log("✅ [WebSocketService] WebSocket Connected!", name: "WebSocket");

      // Start listening to socket stream
      _socket!.listen(
        _onMessageReceived,
        onDone: _onConnectionClosed,
        onError: _onConnectionError,
        cancelOnError: true,
      );
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      print("❌ [WebSocketService] WebSocket connection failed to $url: $e");
      dev.log("❌ [WebSocketService] WebSocket Connection Error: $e", name: "WebSocket");
      _connectionAttempt++; // Cycle to the next candidate URL on failure
      _scheduleReconnect();
    }
  }

  /// Disconnects from the WebSocket Server
  Future<void> disconnect() async {
    print("🔌 [WebSocketService] Disconnecting from WebSocket...");
    dev.log("🔌 [WebSocketService] Disconnecting from WebSocket...", name: "WebSocket");

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    _isConnected = false;
    _isConnecting = false;
    _socketId = null;
    _connectionAttempt = 0;
    _activeChannels.clear();

    if (_socket != null) {
      try {
        await _socket!.close();
      } catch (e) {
        dev.log("⚠️ [WebSocketService] Error closing socket: $e", name: "WebSocket");
      }
      _socket = null;
    }
    print("🔌 [WebSocketService] WebSocket disconnected successfully.");
    dev.log("🔌 [WebSocketService] WebSocket Disconnected.", name: "WebSocket");
  }

  /// Schedules a reconnection attempt after a short delay
  void _scheduleReconnect() {
    if (!_isConnected && !_isConnecting && SharedPrefManager().isUserLogin) {
      Timer(const Duration(seconds: 5), () {
        if (SharedPrefManager().isUserLogin) {
          dev.log("🔄 [WebSocketService] Retrying WebSocket connection...", name: "WebSocket");
          connect();
        }
      });
    }
  }

  /// Called when WebSocket connection is closed
  void _onConnectionClosed() {
    print("🔌 [WebSocketService] WebSocket connection closed by server.");
    dev.log("🔌 [WebSocketService] Connection Closed.", name: "WebSocket");
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _socketId = null;
    _scheduleReconnect();
  }

  /// Called when there's an error on the WebSocket stream
  void _onConnectionError(error) {
    print("❌ [WebSocketService] WebSocket stream error: $error");
    dev.log("❌ [WebSocketService] Stream Error: $error", name: "WebSocket");
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _socketId = null;
    _scheduleReconnect();
  }

  /// Process incoming messages
  void _onMessageReceived(dynamic message) {
    try {
      final Map<String, dynamic> payload = jsonDecode(message.toString());
      final String? event = payload["event"];
      final dynamic rawData = payload["data"];

      if (event == null) return;

      // Handle system events
      if (event == "pusher:connection_established") {
        final Map<String, dynamic> data = rawData is String ? jsonDecode(rawData) : Map<String, dynamic>.from(rawData);
        _socketId = data["socket_id"];
        final int activityTimeout = data["activity_timeout"] ?? 30;
        print("✅ [WebSocketService] Handshake established. Socket ID: $_socketId");
        dev.log("✅ [WebSocketService] Handshake established: $_socketId", name: "WebSocket");

        // Start Ping/Heartbeat
        _startHeartbeat(activityTimeout);

        // Resubscribe to previous channels on reconnection
        _resubscribeToAll();
      } else if (event == "pusher:pong") {
        // Heartbeat response received
      } else if (event == "pusher:error") {
        print("❌ [WebSocketService] Reverb server error event: $rawData");
        dev.log("❌ [WebSocketService] Server Error Event: $rawData", name: "WebSocket");
      } else {
        // App/Channel events
        final String? channel = payload["channel"];
        _triggerEvent(event, channel, rawData);
      }
    } catch (e) {
      dev.log("⚠️ [WebSocketService] Error parsing incoming message: $e", name: "WebSocket");
    }
  }

  /// Start pinging Reverb to keep connection alive
  void _startHeartbeat(int timeoutSeconds) {
    _heartbeatTimer?.cancel();
    final Duration duration = Duration(seconds: timeoutSeconds - 5 > 0 ? timeoutSeconds - 5 : 25);
    _heartbeatTimer = Timer.periodic(duration, (timer) {
      if (_isConnected && _socket != null) {
        _socket!.add(jsonEncode({
          "event": "pusher:ping",
          "data": {}
        }));
      } else {
        timer.cancel();
      }
    });
  }

  /// Subscribe to a channel (Public, Private, or Presence)
  Future<void> subscribe(String channelName) async {
    if (!_isConnected || _socket == null) {
      dev.log("⚠️ [WebSocketService] Cannot subscribe to $channelName: Socket is not connected.", name: "WebSocket");
      _activeChannels.add(channelName); // Save for when it connects
      return;
    }

    if (_activeChannels.contains(channelName)) {
      return; // Already subscribed
    }

    _activeChannels.add(channelName);
    print("📡 [WebSocketService] Subscribing to channel: $channelName");
    dev.log("📡 [WebSocketService] Subscribing to $channelName", name: "WebSocket");

    try {
      if (channelName.startsWith("private-") || channelName.startsWith("presence-")) {
        // Authenticate with backend
        await _subscribePrivateOrPresence(channelName);
      } else {
        // Subscribe to public channel
        _socket!.add(jsonEncode({
          "event": "pusher:subscribe",
          "data": {
            "channel": channelName
          }
        }));
      }
    } catch (e) {
      print("❌ [WebSocketService] Subscription failed for channel $channelName: $e");
      dev.log("❌ [WebSocketService] Subscription Error ($channelName): $e", name: "WebSocket");
    }
  }

  /// Handle private/presence channel subscription authentication
  Future<void> _subscribePrivateOrPresence(String channelName) async {
    final String? token = SharedPrefManager().token;
    if (token == null || token.isEmpty) {
      throw Exception("User Token is missing. Private channel authentication is not possible.");
    }

    if (_socketId == null) {
      throw Exception("Socket ID is not established. Cannot authenticate channel.");
    }

    // Call Broadcasting Auth endpoint
    final Uri authUri = Uri.parse(_authUrl);
    final response = await http.post(
      authUri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "socket_id": _socketId,
        "channel_name": channelName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to authenticate channel: Server returned status ${response.statusCode} - ${response.body}");
    }

    final Map<String, dynamic> authData = jsonDecode(response.body);
    final String? authSignature = authData["auth"];
    final String? channelData = authData["channel_data"];

    if (authSignature == null) {
      throw Exception("Auth signature not returned by server.");
    }

    // Send subscribe event to Reverb
    final Map<String, dynamic> subscribeData = {
      "channel": channelName,
      "auth": authSignature,
    };

    if (channelData != null) {
      subscribeData["channel_data"] = channelData;
    }

    _socket!.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": subscribeData
    }));
    print("✅ [WebSocketService] Sent subscribe payload to $channelName");
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    if (_activeChannels.contains(channelName)) {
      _activeChannels.remove(channelName);
      print("📡 [WebSocketService] Unsubscribing from channel: $channelName");
      dev.log("📡 [WebSocketService] Unsubscribing from $channelName", name: "WebSocket");

      if (_isConnected && _socket != null) {
        _socket!.add(jsonEncode({
          "event": "pusher:unsubscribe",
          "data": {
            "channel": channelName
          }
        }));
      }
    }
  }

  /// Re-subscribe to all active channels (e.g. after reconnection)
  void _resubscribeToAll() {
    if (_activeChannels.isEmpty) return;
    dev.log("🔄 [WebSocketService] Re-subscribing to ${_activeChannels.length} channels...", name: "WebSocket");
    final List<String> channels = _activeChannels.toList();
    _activeChannels.clear();
    for (final String channel in channels) {
      subscribe(channel);
    }
  }

  /// Register an event listener
  void listen(String eventName, Function(dynamic data) callback) {
    if (!_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName] = [];
    }
    _eventListeners[eventName]!.add(callback);
  }

  /// Unregister an event listener
  void removeListener(String eventName, Function(dynamic data) callback) {
    if (_eventListeners.containsKey(eventName)) {
      _eventListeners[eventName]!.remove(callback);
      if (_eventListeners[eventName]!.isEmpty) {
        _eventListeners.remove(eventName);
      }
    }
  }

  /// Trigger registered callbacks for an event
  void _triggerEvent(String eventName, String? channel, dynamic rawData) {
    if (_eventListeners.containsKey(eventName)) {
      final dynamic data = rawData is String ? jsonDecode(rawData) : rawData;
      for (final Function(dynamic) callback in _eventListeners[eventName]!) {
        try {
          callback(data);
        } catch (e) {
          dev.log("⚠️ [WebSocketService] Error running event callback for $eventName: $e", name: "WebSocket");
        }
      }
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
