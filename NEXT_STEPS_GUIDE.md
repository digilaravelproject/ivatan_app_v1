# Next Steps Guide - Chat Features

## 🎯 Quick Implementation Guide for Remaining Features

---

## Feature 1: Clickable Group Details in AppBar

### Where to Add:
`/lib/features/messages/persentation/chatting_screen.dart`

### What to Change:
In `_buildAppBar()` method, wrap the title section with `InkWell`:

```dart
title: InkWell(
  onTap: () {
    // Only for group chats
    if (controller.chatProfile.value?.type == "group") {
      Get.toNamed(
        AppRoutes.groupDetailsScreen,
        arguments: controller.chatProfile.value,
      );
    }
  },
  child: Obx(() {
    final profile = controller.chatProfile.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile?.name ?? "User",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          profile?.type == "group" 
            ? "${profile?.participantsCount ?? 0} participants"
            : "Online",
          style: const TextStyle(
            fontSize: 12,
            color: Colors.green,
          ),
        ),
      ],
    );
  }),
),
```

---

## Feature 2: Read Receipts for Group Messages

### Step 1: Add to Message Long-Press Menu
In `_showMessageOptions()` method, add this option (only for group chats):

```dart
// Add after "Copy" option
if (controller.chatProfile.value?.type == "group" && message.isMine)
  _buildOptionRow(
    icon: Icons.done_all_rounded,
    label: "Read by",
    color: Colors.blue,
    onTap: () {
      Navigator.pop(ctx);
      _showReadReceipts(context, message.id);
    },
  ),
```

### Step 2: Create Read Receipts Bottom Sheet
Add this method to `ChattingScreen` class:

```dart
Future<void> _showReadReceipts(BuildContext context, int messageId) async {
  // Show loading bottom sheet
  Get.bottomSheet(
    Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            "Read by",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    ),
    isDismissible: true,
  );

  // Fetch read receipts
  try {
    final api = Get.find<ApiServices>();
    final response = await api.callGet(
      "api/v1/chats/messages/$messageId/read-receipts"
    );

    if (response != null && response['status'] == true) {
      final List<dynamic> receipts = response['data']['read_by'] ?? [];
      
      // Close loading sheet and show data
      Get.back();
      
      Get.bottomSheet(
        Container(
          height: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Read by",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: receipts.isEmpty
                    ? const Center(child: Text("No read receipts yet"))
                    : ListView.builder(
                        itemCount: receipts.length,
                        itemBuilder: (ctx, index) {
                          final receipt = receipts[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: receipt['user']['avatar'] != null
                                  ? NetworkImage(receipt['user']['avatar'])
                                  : null,
                              child: receipt['user']['avatar'] == null
                                  ? Text(receipt['user']['name'][0])
                                  : null,
                            ),
                            title: Text(receipt['user']['name']),
                            subtitle: Text(
                              _formatReadTime(receipt['read_at']),
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        isDismissible: true,
      );
    }
  } catch (e) {
    Get.back();
    CustomSnackBar.showError(message: "Failed to load read receipts");
  }
}

String _formatReadTime(String dateTimeString) {
  try {
    final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays > 0) {
      return DateFormat('MMM dd, hh:mm a').format(dateTime);
    } else if (diff.inHours > 0) {
      return "${diff.inHours}h ago";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes}m ago";
    } else {
      return "Just now";
    }
  } catch (e) {
    return "";
  }
}
```

---

## Feature 3: Complete Group Management APIs

### Step 1: Add to LiveChatRepository
File: `/lib/features/quick_access/persentation/live_chat/repository/live_chat_repository.dart`

Add these methods:

```dart
/// Add participants to group
Future<bool> addParticipants(int chatId, List<int> userIds) async {
  try {
    final String endpoint = "api/v1/chats/$chatId/participants";
    
    Map<String, dynamic> data = {};
    for (int i = 0; i < userIds.length; i++) {
      data['user_ids[$i]'] = userIds[i];
    }
    
    final response = await _api.callPost(
      endpoint,
      data: data,
      isFormData: true,
      showErrorToast: true,
    );
    
    return response != null && response['status'] == true;
  } catch (e) {
    print("Error in LiveChatRepository.addParticipants: $e");
    return false;
  }
}

/// Remove participant from group
Future<bool> removeParticipant(int chatId, int userId) async {
  try {
    final String endpoint = "api/v1/chats/$chatId/participants/$userId";
    
    final response = await _api.callDelete(
      endpoint,
      showErrorToast: true,
    );
    
    return response != null && response['status'] == true;
  } catch (e) {
    print("Error in LiveChatRepository.removeParticipant: $e");
    return false;
  }
}

/// Leave group
Future<bool> leaveGroup(int chatId) async {
  try {
    final String endpoint = "api/v1/chats/$chatId/leave";
    
    final response = await _api.callPost(
      endpoint,
      data: {},
      showErrorToast: true,
    );
    
    return response != null && response['status'] == true;
  } catch (e) {
    print("Error in LiveChatRepository.leaveGroup: $e");
    return false;
  }
}
```

### Step 2: Wire up in GroupDetailsScreen
File: `/lib/features/messages/persentation/group_details_screen.dart`

Update these methods:

```dart
Future<void> _addParticipants() async {
  // Navigate to contact selection
  final selectedUserIds = await Get.toNamed(
    AppRoutes.createGroupScreen, // Reuse the same screen
    arguments: {'mode': 'add_participants'}, // Add mode flag
  );
  
  if (selectedUserIds != null && selectedUserIds is List<int>) {
    final repository = LiveChatRepository();
    final success = await repository.addParticipants(
      groupData.id,
      selectedUserIds,
    );
    
    if (success) {
      CustomSnackBar.showSuccess(message: "Participants added!");
      _fetchGroupDetails(); // Refresh
    }
  }
}

Future<void> _removeParticipant(int userId) async {
  final confirm = await Get.dialog<bool>(
    AlertDialog(
      title: const Text("Remove Participant"),
      content: const Text("Are you sure you want to remove this participant?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Remove"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    final repository = LiveChatRepository();
    final success = await repository.removeParticipant(
      groupData.id,
      userId,
    );
    
    if (success) {
      CustomSnackBar.showSuccess(message: "Participant removed");
      _fetchGroupDetails(); // Refresh
    }
  }
}

Future<void> _leaveGroup() async {
  final confirm = await Get.dialog<bool>(
    AlertDialog(
      title: const Text("Leave Group"),
      content: const Text("Are you sure you want to leave this group?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("Leave"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    final repository = LiveChatRepository();
    final success = await repository.leaveGroup(groupData.id);
    
    if (success) {
      CustomSnackBar.showSuccess(message: "Left the group");
      Get.back(); // Close details
      Get.back(); // Close chat
    }
  }
}
```

---

## Feature 4: WebSocket Events for Groups

### Add to ChatMessagesController
File: `/lib/features/messages/controller/chat_message_controller.dart`

In `initPusher()` method, add more event listeners:

```dart
// Add after existing listeners
wsService.listen("group.created", _onGroupCreated);
wsService.listen("participant.added", _onParticipantAdded);
wsService.listen("participant.removed", _onParticipantRemoved);
wsService.listen("participant.left", _onParticipantLeft);
```

Add handler methods:

```dart
void _onGroupCreated(dynamic data) {
  try {
    print("🔥 [ChatMessagesController] Group created: $data");
    // Refresh chat list
    if (Get.isRegistered<ChattController>()) {
      Get.find<ChattController>().fetchInbox();
    }
  } catch (e) {
    print("Error handling group.created: $e");
  }
}

void _onParticipantAdded(dynamic data) {
  try {
    print("🔥 [ChatMessagesController] Participant added: $data");
    var parsedData = data is String ? jsonDecode(data) : data;
    final int chatId = parsedData["chat_id"] ?? 0;
    
    if (chatId == chatProfile.value?.id) {
      // Refresh group details
      CustomSnackBar.showInfo(
        message: "${parsedData['user']['name']} was added to the group"
      );
    }
  } catch (e) {
    print("Error handling participant.added: $e");
  }
}

void _onParticipantRemoved(dynamic data) {
  try {
    print("🔥 [ChatMessagesController] Participant removed: $data");
    var parsedData = data is String ? jsonDecode(data) : data;
    final int chatId = parsedData["chat_id"] ?? 0;
    
    if (chatId == chatProfile.value?.id) {
      CustomSnackBar.showInfo(
        message: "${parsedData['user']['name']} was removed from the group"
      );
    }
  } catch (e) {
    print("Error handling participant.removed: $e");
  }
}

void _onParticipantLeft(dynamic data) {
  try {
    print("🔥 [ChatMessagesController] Participant left: $data");
    var parsedData = data is String ? jsonDecode(data) : data;
    final int chatId = parsedData["chat_id"] ?? 0;
    
    if (chatId == chatProfile.value?.id) {
      CustomSnackBar.showInfo(
        message: "${parsedData['user']['name']} left the group"
      );
    }
  } catch (e) {
    print("Error handling participant.left: $e");
  }
}
```

Don't forget to remove listeners in `onClose()`:

```dart
@override
void onClose() {
  focusNode.dispose();
  final chatId = chatProfile.value?.id;
  if (chatId != null) {
    try {
      final wsService = Get.find<WebSocketService>();
      wsService.removeListener("message.sent", _onMessageSent);
      wsService.removeListener("message.edited", _onMessageEdited);
      wsService.removeListener("message.deleted", _onMessageDeleted);
      wsService.removeListener("group.created", _onGroupCreated);
      wsService.removeListener("participant.added", _onParticipantAdded);
      wsService.removeListener("participant.removed", _onParticipantRemoved);
      wsService.removeListener("participant.left", _onParticipantLeft);
      wsService.unsubscribe("presence-presence-chat.$chatId");
    } catch (e) {
      print("WebSocket unsubscribe error on onClose: $e");
    }
  }
  messageController.dispose();
  super.onClose();
}
```

---

## Feature 5: Reply to Messages

### Step 1: Add Reply State to Controller
File: `/lib/features/messages/controller/chat_message_controller.dart`

Add these properties:

```dart
var replyingTo = Rxn<ChatMessage>(); // Track which message is being replied to

void setReplyTo(ChatMessage? message) {
  replyingTo.value = message;
}

void cancelReply() {
  replyingTo.value = null;
}
```

### Step 2: Update Send Message to Include Reply
In `sendMessage()` method:

```dart
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
    
    Map<String, dynamic> data = {
      "content": m,
      "message_type": "text",
    };
    
    // Add reply_to if replying
    if (replyingTo.value != null) {
      data["reply_to_message_id"] = replyingTo.value!.id;
    }
    
    final response = await api.callPost(
      "api/v1/chats/${p.id}/messages",
      data: data,
    );

    if (response != null && response["status"] == true) {
      final newMessage = ChatMessage.fromJson(response['data']);
      final index = messages.indexWhere((m) => m.id == newMessage.id);
      if (index == -1) {
        messages.insert(0, newMessage);
      } else {
        messages[index] = newMessage;
      }
      messages.refresh();
      messageController.clear();
      cancelReply(); // Clear reply state
      
      // Update chat list...
    }
  } catch (e, stk) {
    print("sendMessage error: $e,\n$stk");
  } finally {
    isSendingMessage.value = false;
  }
}
```

### Step 3: Add Reply Preview UI
In `_buildInputArea()` method in `chatting_screen.dart`:

Add this before the input row:

```dart
// Reply Preview
Obx(() {
  if (controller.replyingTo.value == null) return const SizedBox.shrink();
  
  final replyMsg = controller.replyingTo.value!;
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      border: Border(
        left: BorderSide(color: AppColors.primary, width: 3),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                replyMsg.sender?.name ?? "User",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                replyMsg.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => controller.cancelReply(),
        ),
      ],
    ),
  );
}),
```

### Step 4: Update Message Options
In `_showMessageOptions()`, update reply option:

```dart
_buildOptionRow(
  icon: Icons.reply_rounded,
  label: "Reply",
  color: Colors.black87,
  onTap: () {
    Navigator.pop(ctx);
    controller.setReplyTo(message);
    controller.focusNode.requestFocus(); // Focus input
  },
),
```

---

## 📝 Testing Checklist

### For Each Feature:
- [ ] Feature 1: Click group AppBar → opens details
- [ ] Feature 2: Long-press message in group → "Read by" option
- [ ] Feature 3: Add/remove participants works
- [ ] Feature 4: WebSocket events trigger correctly
- [ ] Feature 5: Reply to message shows preview

### Regression Testing:
- [ ] Normal chat still works
- [ ] Group creation still works
- [ ] Messages still display correctly
- [ ] WebSocket still connects

---

## 🐛 Common Issues & Solutions

### Issue: WebSocket not connecting
**Solution**: Check token is valid, Reverb server is running

### Issue: Read receipts not loading
**Solution**: Verify API endpoint exists, check response structure

### Issue: Participants not updating
**Solution**: Ensure WebSocket events are being broadcast by backend

### Issue: Reply preview not clearing
**Solution**: Call `cancelReply()` after sending message

---

## 📞 Need Help?

1. Check console logs (look for emoji prefixes)
2. Verify API response structures match expectations
3. Test WebSocket connection with `wsService.isConnected`
4. Review `IMPLEMENTATION_SUMMARY.md` for completed features

---

**Priority Order**: Feature 1 → Feature 2 → Feature 3 → Feature 4 → Feature 5

**Estimated Time**: 
- Feature 1: 15 minutes
- Feature 2: 1 hour
- Feature 3: 1.5 hours
- Feature 4: 1 hour
- Feature 5: 1.5 hours
**Total: ~5.5 hours**
