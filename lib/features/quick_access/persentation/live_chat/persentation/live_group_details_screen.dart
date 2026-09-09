import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import '../model/live_chat_group_details_model.dart';
import '../repository/live_chat_repository.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR GROUP DETAILS SCREEN
// =========================================================================
class LiveGroupDetailsController extends GetxController {
  final int chatId;
  final String initialName;
  final Color avatarColor;
  final int initialParticipantsCount;
  final String initialChatMode;
  final bool initialIsAdmin;
  final String initialDescription;

  final LiveChatRepository _repository = Get.put(LiveChatRepository());
  final FocusNode focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();

  LiveGroupDetailsController({
    required this.chatId,
    required this.initialName,
    required this.avatarColor,
    required this.initialParticipantsCount,
    required this.initialChatMode,
    required this.initialIsAdmin,
    required this.initialDescription,
  });

  var isLoading = false.obs;
  var groupDetail = Rxn<LiveChatGroupModel>();

  RxBool isMuted = false.obs;
  RxBool isBanned = false.obs;

  var isSearchExpanded = false.obs;
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    isMuted.value = initialName == "Announcements" ? true : false;
    fetchDetails();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      final detail = await _repository.fetchGroupDetails(chatId);
      if (detail != null) {
        groupDetail.value = detail;
      }
    } catch (e) {
      print("Error fetching group details in controller: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMuted(bool val) {
    isMuted.value = val;
  }

  void toggleBanned(bool val) {
    isBanned.value = val;
  }

  // Getters that fallback to arguments safely
  String get groupName => groupDetail.value?.name ?? initialName;
  String get groupDescription {
    final desc = groupDetail.value?.description;
    if (desc == null || desc.trim().isEmpty) {
      return "No description provided.";
    }
    return desc;
  }
  int get participantsCount => groupDetail.value?.participants.length ?? initialParticipantsCount;
  String get chatMode => groupDetail.value?.chatMode ?? initialChatMode;
  
  bool get isAdmin {
    final currentUserId = SharedPrefManager().user?.id;
    if (currentUserId == null) return initialIsAdmin;
    return groupDetail.value?.participants.any((p) => p.user?.id == currentUserId && p.role == 'admin') ?? initialIsAdmin;
  }

  String get createdByName => groupDetail.value?.createdBy?.name ?? "Super Admin";

  String get formattedCreatedAt {
    final rawDate = groupDetail.value?.createdAt;
    if (rawDate == null || rawDate.isEmpty) return "01 May, 2026";
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return "${parsed.day} ${months[parsed.month - 1]}, ${parsed.year}";
      }
    } catch (_) {}
    return rawDate;
  }

  List<ParticipantModel> get filteredParticipants {
    final participants = groupDetail.value?.participants ?? [];
    if (searchQuery.value.trim().isEmpty) {
      return participants;
    }
    final query = searchQuery.value.trim().toLowerCase();
    return participants.where((p) {
      final name = p.user?.name.toLowerCase() ?? "";
      final username = p.user?.username?.toLowerCase() ?? "";
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  void showParticipantOptions(BuildContext context, ParticipantModel participant) {
    final currentUserId = SharedPrefManager().user?.id;
    final isMe = participant.user?.id == currentUserId;
    final isTargetAdmin = participant.role == 'admin';
    final amIAdmin = groupDetail.value?.participants
        .any((p) => p.user?.id == currentUserId && p.role == 'admin') ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 20 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor.withOpacity(0.15),
                    backgroundImage: participant.user?.avatar != null && participant.user!.avatar!.isNotEmpty
                        ? NetworkImage(AppUrls.getFullImageUrl(participant.user?.avatar))
                        : null,
                    child: (participant.user?.avatar == null || participant.user!.avatar!.isEmpty)
                        ? Text(
                            (participant.user?.name ?? "U")[0].toUpperCase(),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: avatarColor),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          participant.user?.name ?? "User",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                        if (participant.user?.username != null)
                          Text(
                            "@${participant.user!.username}",
                            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.premiumGold.withOpacity(0.6)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              
              ListTile(
                leading: const Icon(Icons.message_outlined, color: AppColors.white),
                title: Text("Message ${participant.user?.name ?? 'User'}", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  Get.back(); // Go back to group chat
                  CustomSnackBar.showInfo(message: "Direct messaging coming soon!");
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: AppColors.white),
                title: Text("View Profile", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  CustomSnackBar.showInfo(message: "Profile view is only available on main social feed.");
                },
              ),

              if (amIAdmin && !isMe) ...[
                ListTile(
                  leading: Icon(isTargetAdmin ? Icons.remove_circle_outline_rounded : Icons.star_border_rounded, 
                               color: isTargetAdmin ? Colors.redAccent : AppColors.accent),
                  title: Text(
                    isTargetAdmin ? "Dismiss as Admin" : "Make Group Admin",
                    style: GoogleFonts.poppins(color: isTargetAdmin ? Colors.redAccent : AppColors.accent),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    CustomSnackBar.showSuccess(
                      message: isTargetAdmin 
                          ? "${participant.user?.name} dismissed as admin (Simulation)" 
                          : "${participant.user?.name} is now a Group Admin (Simulation)"
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove_outlined, color: Colors.red),
                  title: Text(
                    "Remove ${participant.user?.name}",
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    CustomSnackBar.showSuccess(message: "${participant.user?.name} removed from group (Simulation)");
                  },
                ),
              ],
              
              ListTile(
                leading: Icon(Icons.close_rounded, color: AppColors.premiumGold),
                title: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.premiumGold)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// 🎨 LIVE GROUP DETAILS SCREEN (WHATSAPP-STYLE REVAMPED UI)
// =========================================================================
class LiveGroupDetailsScreen extends StatelessWidget {
  const LiveGroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int chatId = args['chat_id'] ?? 1;
    final String name = args['name'] ?? "Group";
    final Color avatarColor = args['avatar_color'] ?? const Color(0xFF0F9D58);
    final int participantsCount = args['participants_count'] ?? 1;
    final String chatMode = args['chat_mode'] ?? "everyone";
    final bool isAdmin = args['is_admin'] ?? false;
    final String description = args['description'] ?? "No description.";

    final controller = Get.put(
      LiveGroupDetailsController(
        chatId: chatId,
        initialName: name,
        avatarColor: avatarColor,
        initialParticipantsCount: participantsCount,
        initialChatMode: chatMode,
        initialIsAdmin: isAdmin,
        initialDescription: description,
      ),
      tag: chatId.toString(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Soft WhatsApp background grey
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0.5,
        title: Text(
          "Group Info",
          style: GoogleFonts.poppins(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
            size: 20,
          ),
        ),

      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header block (Avatar, Title, Count, Actions)
                  _buildHeaderBlock(context, controller),
                  const SizedBox(height: 12),

                  // 2. Description Block
                  _buildDescriptionBlock(controller),
                  const SizedBox(height: 12),

                  // 3. Details Parameters Block
                  _buildDetailsBlock(controller),
                  const SizedBox(height: 12),

                  // 4. Switches Block
                  // _buildSwitchesBlock(controller),
                  // const SizedBox(height: 12),

                  // 5. Participants List Block
                  _buildParticipantsBlock(context, controller),
                  const SizedBox(height: 16),

                  // 6. Primary Action Buttons
                  _buildActionButtonsBlock(context, controller),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (controller.isLoading.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 3,
                ),
              ),
          ],
        );
      }),
    );
  }

  // 1. Top Header Block
  Widget _buildHeaderBlock(BuildContext context, LiveGroupDetailsController controller) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      width: double.infinity,
      child: Column(
        children: [
          Hero(
            tag: 'group-avatar-${controller.chatId}',
            child: CircleAvatar(
              radius: 54,
              backgroundColor: controller.avatarColor.withOpacity(0.15),
              backgroundImage: controller.groupDetail.value?.avatar != null && controller.groupDetail.value!.avatar!.isNotEmpty
                  ? NetworkImage(AppUrls.getFullImageUrl(controller.groupDetail.value?.avatar))
                  : null,
              child: (controller.groupDetail.value?.avatar == null || controller.groupDetail.value!.avatar!.isEmpty)
                  ? Icon(
                      Icons.groups_rounded,
                      color: controller.avatarColor,
                      size: 60,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            controller.groupName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            "Group · ${controller.participantsCount} participants",
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppColors.premiumGold.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          // const SizedBox(height: 20),
          //
          // // Actions row (Mute, Add, Search)
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _buildHeaderAction(
          //       icon: controller.isMuted.value ? Icons.volume_off_rounded : Icons.notifications_none_rounded,
          //       label: controller.isMuted.value ? "Unmute" : "Mute",
          //       onTap: () => controller.toggleMuted(!controller.isMuted.value),
          //       color: controller.isMuted.value ? Colors.redAccent : AppColors.accent,
          //     ),
          //     const SizedBox(width: 32),
          //     _buildHeaderAction(
          //       icon: Icons.person_add_alt_1_rounded,
          //       label: "Add",
          //       onTap: () {
          //         CustomSnackBar.showInfo(message: "Add participant feature is coming soon!");
          //       },
          //       color: AppColors.accent,
          //     ),
          //     const SizedBox(width: 32),
          //     _buildHeaderAction(
          //       icon: Icons.search_rounded,
          //       label: "Search",
          //       onTap: () {
          //         controller.isSearchExpanded.value = !controller.isSearchExpanded.value;
          //         if (controller.isSearchExpanded.value) {
          //           controller.focusNode.requestFocus();
          //         } else {
          //           controller.searchQuery.value = "";
          //           controller.searchController.clear();
          //         }
          //       },
          //       color: AppColors.accent,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.08),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Description Block
  Widget _buildDescriptionBlock(LiveGroupDetailsController controller) {
    return Container(
      color: AppColors.black,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.groupDescription,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppColors.premiumGold.withOpacity(0.8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Created by ${controller.createdByName}, on ${controller.formattedCreatedAt}",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.premiumGold.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Details Parameters Block
  Widget _buildDetailsBlock(LiveGroupDetailsController controller) {
    return Container(
      color: AppColors.black,
      width: double.infinity,
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.chat_bubble_outline_rounded,
            label: "Chat Mode",
            value: controller.chatMode == "admin_only" ? "Admin Only" : "Everyone",
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.tag_rounded,
            label: "Group ID",
            value: "${controller.chatId}",
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.info_outline_rounded,
            label: "Group Status",
            value: "Active",
            valueColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.black, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.premiumGold.withOpacity(0.65),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
    );
  }

  // 4. Switches List Block
  Widget _buildSwitchesBlock(LiveGroupDetailsController controller) {
    return Container(
      color: AppColors.black,
      width: double.infinity,
      child: Column(
        children: [
          Obx(() => _buildSwitchRow(
                icon: Icons.volume_off_rounded,
                label: "Mute Notifications",
                value: controller.isMuted.value,
                onChanged: controller.toggleMuted,
              )),
          _buildDivider(),
          Obx(() => _buildSwitchRow(
                icon: Icons.gavel_rounded,
                label: "Banned / Blocked",
                value: controller.isBanned.value,
                onChanged: controller.toggleBanned,
              )),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.black, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.premiumGold.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.black,
            activeTrackColor: AppColors.premiumGold,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: Colors.grey.shade800,
          ),
        ],
      ),
    );
  }

  // 5. Participants List Block
  Widget _buildParticipantsBlock(BuildContext context, LiveGroupDetailsController controller) {
    return Material(
      color: AppColors.black,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${controller.participantsCount} participants",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.premiumGold.withOpacity(0.8),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    controller.isSearchExpanded.value ? Icons.close_rounded : Icons.search_rounded,
                    color: AppColors.premiumGold.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () {
                    controller.isSearchExpanded.value = !controller.isSearchExpanded.value;
                    if (!controller.isSearchExpanded.value) {
                      controller.searchQuery.value = "";
                      controller.searchController.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          if (controller.isSearchExpanded.value)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: controller.searchController,
                  focusNode: controller.focusNode,
                  style: GoogleFonts.poppins(fontSize: 13.5),
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: "Search participants...",
                    hintStyle: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.4), fontSize: 13.5),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),

          if (controller.filteredParticipants.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  "No participants found",
                  style: GoogleFonts.poppins(color: AppColors.premiumGold.withOpacity(0.5), fontSize: 13.5),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredParticipants.length,
              itemBuilder: (context, index) {
                final participant = controller.filteredParticipants[index];
                final bool isUserAdmin = participant.role == 'admin';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: controller.avatarColor.withOpacity(0.12),
                    backgroundImage: participant.user?.avatar != null && participant.user!.avatar!.isNotEmpty
                        ? NetworkImage(AppUrls.getFullImageUrl(participant.user?.avatar))
                        : null,
                    child: (participant.user?.avatar == null || participant.user!.avatar!.isEmpty)
                        ? Text(
                            (participant.user?.name ?? "U")[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: controller.avatarColor,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    participant.user?.name ?? "User",
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  subtitle: participant.user?.username != null
                      ? Text(
                          "@${participant.user!.username}",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.premiumGold.withOpacity(0.6),
                          ),
                        )
                      : null,
                  trailing: isUserAdmin
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Admin",
                            style: GoogleFonts.poppins(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => controller.showParticipantOptions(context, participant),
                );
              },
            ),
        ],
      ),
    ),
  );
}

  // 6. Exit / View Messages Buttons Block
  Widget _buildActionButtonsBlock(BuildContext context, LiveGroupDetailsController controller) {
    return Material(
      color: AppColors.black,
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accent),
              title: Text(
                "View Messages",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            // _buildDivider(),
            // ListTile(
            //   leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
            //   title: Text(
            //     "Exit Group",
            //     style: GoogleFonts.poppins(
            //       fontWeight: FontWeight.w600,
            //       color: Colors.red,
            //     ),
            //   ),
            //   onTap: () {
            //     Get.defaultDialog(
            //       title: "Exit Group",
            //       titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
            //       middleText: "Are you sure you want to exit this group?",
            //       middleTextStyle: GoogleFonts.poppins(fontSize: 14),
            //       textConfirm: "Exit",
            //       confirmTextColor: AppColors.white,
            //       buttonColor: Colors.red,
            //       textCancel: "Cancel",
            //       cancelTextColor: AppColors.premiumGold,
            //       onConfirm: () {
            //         Get.back(); // Close dialog
            //         Get.back(); // Exit details screen
            //         Get.back(); // Exit chat screen
            //         CustomSnackBar.showSuccess(message: "You exited the group (Simulation)");
            //       },
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
