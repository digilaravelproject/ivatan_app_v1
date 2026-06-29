import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import '../controller/chat_message_controller.dart';
import '../model/chat_data_model.dart';
import '../../quick_access/persentation/controller/contact_controller.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({Key? key}) : super(key: key);

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late ChatListModel groupData;
  bool isLoading = true;
  final ChatMessagesController controller = Get.find<ChatMessagesController>();

  @override
  void initState() {
    super.initState();
    if (Get.arguments is ChatListModel) {
      groupData = Get.arguments as ChatListModel;
      _fetchGroupDetails();
    } else {
      isLoading = false;
    }
  }

  Future<void> _fetchGroupDetails() async {
    setState(() => isLoading = true);
    final fresh = await controller.fetchGroupDetails(groupData.id);
    if (fresh != null && mounted) {
      setState(() {
        groupData = fresh;
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addParticipants() async {
    final selectedIds = await _showContactPicker();
    if (selectedIds == null || selectedIds.isEmpty) return;

    final success = await controller.addParticipants(groupData.id, selectedIds);
    if (success) {
      _fetchGroupDetails();
    }
  }

  Future<List<int>?> _showContactPicker() async {
    final contactController = Get.isRegistered<ContactController>()
        ? Get.find<ContactController>()
        : Get.put(ContactController());
    await contactController.fetchContacts();

    final selected = <int>{}.obs;

    return Get.dialog<List<int>>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      "Add Members",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(result: null),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Obx(() {
                final contacts = contactController.filteredContactList
                    .where((c) => !c.is_mine.value)
                    .toList();
                if (contacts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No contacts available"),
                  );
                }
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final isSelected = selected.contains(contact.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (val) {
                          if (val == true) {
                            selected.add(contact.id);
                          } else {
                            selected.remove(contact.id);
                          }
                        },
                        secondary: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: contact.avatar.isNotEmpty
                              ? NetworkImage(contact.avatar)
                              : null,
                          child: contact.avatar.isEmpty
                              ? Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(contact.name),
                      );
                    },
                  ),
                );
              }),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selected.isEmpty) {
                        CustomSnackBar.showInfo(message: "Select at least one member");
                        return;
                      }
                      Get.back(result: selected.toList());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Add ${selected.length} Member${selected.length != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      final success = await controller.removeParticipant(groupData.id, userId);
      if (success) {
        _fetchGroupDetails();
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
      final success = await controller.leaveGroup(groupData.id);
      if (success) {
        Get.back();
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "Group Info",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final bool isAdmin = groupData.isAdmin == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Group Info",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Group Header
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (groupData.avatar != null &&
                            groupData.avatar.toString().isNotEmpty)
                        ? NetworkImage(groupData.avatar.toString())
                        : null,
                    child: (groupData.avatar == null ||
                            groupData.avatar.toString().isEmpty)
                        ? const Icon(Icons.group, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    groupData.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Group · ${groupData.participantsCount} participants",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Participants Section Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${groupData.participantsCount} Participants",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: Icon(Icons.person_add, color: AppColors.primary),
                      onPressed: _addParticipants,
                    ),
                ],
              ),
            ),

            // Participants List
            if (groupData.participants.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text(
                  "No participants yet",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupData.participants.length,
                separatorBuilder: (ctx, i) => Divider(
                  height: 1,
                  indent: 80,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  final participant = groupData.participants[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: participant.avatar.isNotEmpty
                              ? NetworkImage(participant.avatar)
                              : null,
                          child: participant.avatar.isEmpty
                              ? Text(
                                  participant.name.isNotEmpty
                                      ? participant.name[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    participant.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (participant.isAdmin) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "Admin",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isAdmin && !participant.isAdmin)
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () =>
                                _removeParticipant(participant.userId),
                          ),
                      ],
                    ),
                  );
                },
              ),

            const Divider(height: 32),

            // Leave Group Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _leaveGroup,
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: const Text(
                    "Leave Group",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
