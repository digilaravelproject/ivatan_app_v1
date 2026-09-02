import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import '../controller/chatt_controller.dart';
import '../model/chat_data_model.dart';

/// =========================================================================
/// 🎨 CREATE GROUP SCREEN - WhatsApp Style
/// =========================================================================
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final ChattController chattController = Get.find<ChattController>();
  final ApiServices api = Get.find<ApiServices>();
  final TextEditingController groupNameController = TextEditingController();
  final List<int> selectedUserIds = [];
  File? selectedAvatar;
  bool isCreating = false;
  
  // Contacts data
  List<dynamic> contacts = [];
  bool isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    try {
      setState(() {
        isLoadingContacts = true;
      });

      // Use chat list as contacts for now
      // Filter out groups and show only individual chats
      final individualChats = chattController.chatList
          .where((chat) => chat.type != "group")
          .toList();

      setState(() {
        contacts = individualChats.map((chat) {
          // For individual chats, get the other user's ID from participants
          // The participant who is NOT the current user is the contact
          int? otherUserId;
          String? otherUserName;
          String? otherUserAvatar;
          
          if (chat.participants.isNotEmpty) {
            // Find the participant who is not "me"
            for (var participant in chat.participants) {
              // Assuming the participant with userId is the other user
              // You might need to check against current user ID here
              otherUserId = participant.userId;
              otherUserName = participant.name;
              otherUserAvatar = participant.avatar;
              break; // Take first participant as the contact
            }
          }
          
          return {
            'user_id': otherUserId ?? chat.id, // Use userId, fallback to chat id
            'name': otherUserName ?? chat.name,
            'avatar': otherUserAvatar ?? chat.avatar,
            'chat_id': chat.id, // Keep chat_id for reference
            'type': 'chat',
          };
        }).toList();
        isLoadingContacts = false;
      });

      print("📱 Loaded ${contacts.length} contacts for group creation");
      print("📋 First contact sample: ${contacts.isNotEmpty ? contacts[0] : 'none'}");
    } catch (e) {
      print("❌ Error loading contacts: $e");
      setState(() {
        isLoadingContacts = false;
      });
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedAvatar = File(image.path);
        });
      }
    } catch (e) {
      CustomSnackBar.showError(message: "Error picking image: $e");
    }
  }

  Future<void> _createGroup() async {
    if (groupNameController.text.trim().isEmpty) {
      CustomSnackBar.showError(message: "Please enter group name");
      return;
    }

    if (selectedUserIds.isEmpty) {
      CustomSnackBar.showError(message: "Please select at least one participant");
      return;
    }

    setState(() {
      isCreating = true;
    });

    try {
      // Prepare form data
      Map<String, dynamic> formData = {
        'name': groupNameController.text.trim(),
      };

      // Add avatar if selected
      if (selectedAvatar != null) {
        formData['avatar'] = selectedAvatar!;
      }

      // Add participant IDs as array
      formData['participant_ids'] = selectedUserIds;

      print("🚀 Creating group with data: ${formData.keys}");

      final response = await api.callPost(
        'api/v1/chats/group',
        data: formData,
        isFormData: true,
      );

      print("📦 Create group response: $response");

      if (response != null && response['status'] == true) {
        CustomSnackBar.showSuccess(message: "Group created successfully!");
        
        // Refresh chat list
        await chattController.fetchInbox();
        
        Get.back(); // Close create group screen
      } else {
        CustomSnackBar.showError(
          message: response?['message'] ?? "Failed to create group"
        );
      }
    } catch (e) {
      print("❌ Create group error: $e");
      CustomSnackBar.showError(message: "Failed to create group: $e");
    } finally {
      setState(() {
        isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Group",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Add participants",
              style: TextStyle(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Group Info Section
          Container(
            color: AppColors.premiumGold.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Picker
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.premiumGold,
                      image: selectedAvatar != null
                          ? DecorationImage(
                              image: FileImage(selectedAvatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedAvatar == null
                        ? Icon(Icons.camera_alt, color: AppColors.premiumGold, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Group Name Input
                Expanded(
                  child: TextField(
                    controller: groupNameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Group name",
                      hintStyle: TextStyle(color: AppColors.premiumGold),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Selected Count
          if (selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.premiumGold.withOpacity(0.1),
              child: Row(
                children: [
                  Text(
                    "${selectedUserIds.length} participant${selectedUserIds.length > 1 ? 's' : ''} selected",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Contact List
          Expanded(
            child: isLoadingContacts
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : contacts.isEmpty
                    ? const Center(
                        child: Text("No contacts available"),
                      )
                    : ListView.separated(
                        itemCount: contacts.length,
                        separatorBuilder: (ctx, i) => Divider(
                          height: 1,
                          indent: 80,
                          color: AppColors.premiumGold,
                        ),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final contactUserId = contact['user_id'] as int;
                          final contactName = contact['name'] as String;
                          final contactAvatar = contact['avatar'];
                          final isSelected = selectedUserIds.contains(contactUserId);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedUserIds.remove(contactUserId);
                                } else {
                                  selectedUserIds.add(contactUserId);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: AppColors.premiumGold,
                                    backgroundImage: (contactAvatar != null &&
                                            contactAvatar.toString().isNotEmpty)
                                        ? NetworkImage(contactAvatar.toString())
                                        : null,
                                    child: (contactAvatar == null ||
                                            contactAvatar.toString().isEmpty)
                                        ? Text(
                                            contactName.isNotEmpty
                                                ? contactName[0].toUpperCase()
                                                : "?",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  // Name
                                  Expanded(
                                    child: Text(
                                      contactName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Checkbox
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedUserIds.add(contactUserId);
                                        } else {
                                          selectedUserIds.remove(contactUserId);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: selectedUserIds.isNotEmpty
          ? FloatingActionButton(
              onPressed: isCreating ? null : _createGroup,
              backgroundColor: AppColors.primary,
              child: isCreating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.arrow_forward, color: AppColors.white),
            )
          : null,
    );
  }
}
