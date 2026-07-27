import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import '../controller/chat_message_controller.dart';
import '../model/chat_data_model.dart';
import '../../quick_access/persentation/controller/contact_controller.dart';
import '../controller/chatt_controller.dart';
import 'dart:ui';

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
                final existingParticipantIds = groupData.participants.map((p) => p.userId).toSet();
                final contacts = contactController.filteredContactList
                    .where((c) => !c.is_mine.value && c.type == 'registered' && c.id != 0 && !existingParticipantIds.contains(c.id))
                    .toList();
                if (contacts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("All contacts are already in the group!"),
                  );
                }
                return Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Obx(() {
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
                      });
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
                    child: Obx(() => Text(
                      "Add ${selected.length} Member${selected.length != 1 ? 's' : ''}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Leave Group", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to leave this group? You will no longer receive messages from it."),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text("Leave", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await controller.leaveGroup(groupData.id);
      if (success) {
        if (Get.isRegistered<ChattController>()) {
          Get.find<ChattController>().fetchInboxGroup();
        }
        Get.back();
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final bool isAdmin = groupData.isAdmin == 1;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Premium soft background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Beautiful blurred background matching the avatar
                  if (groupData.avatar != null && groupData.avatar.toString().isNotEmpty)
                    Image.network(
                      groupData.avatar.toString(),
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: AppColors.primary),
                  
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),

                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (groupData.avatar != null && groupData.avatar.toString().isNotEmpty)
                              ? NetworkImage(groupData.avatar.toString())
                              : null,
                          child: (groupData.avatar == null || groupData.avatar.toString().isEmpty)
                              ? const Icon(Icons.groups_rounded, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        groupData.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${groupData.participantsCount} participants",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Participants Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Members",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              if (isAdmin)
                                GestureDetector(
                                  onTap: _addParticipants,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_add_rounded, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Add",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        if (groupData.participants.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "No members yet",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupData.participants.length,
                            separatorBuilder: (ctx, i) => Divider(
                              height: 1,
                              indent: 70,
                              color: Colors.grey.shade100,
                            ),
                            itemBuilder: (context, index) {
                              final participant = groupData.participants[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  backgroundImage: participant.avatar.isNotEmpty
                                      ? NetworkImage(participant.avatar)
                                      : null,
                                  child: participant.avatar.isEmpty
                                      ? Text(
                                          participant.name.isNotEmpty
                                              ? participant.name[0].toUpperCase()
                                              : "?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        participant.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (participant.isAdmin)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "Admin",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: (isAdmin && !participant.isAdmin)
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.person_remove_rounded,
                                          color: Colors.red.shade400,
                                        ),
                                        onPressed: () => _removeParticipant(participant.userId),
                                        splashRadius: 20,
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Leave Group Button
                  GestureDetector(
                    onTap: _leaveGroup,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade100.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.exit_to_app_rounded, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(
                            "Leave Group",
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//}
