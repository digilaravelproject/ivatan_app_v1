import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:i_vatan_app/core/theme/app_colors.dart';

// =========================================================================
// 🚀 GETX CONTROLLER FOR GROUP DETAILS SCREEN (MATCHES MOCKUP SCREEN 4)
// =========================================================================
class LiveGroupDetailsController extends GetxController {
  final int chatId;
  final String name;
  final Color avatarColor;
  final int participantsCount;
  final String chatMode;
  final bool isAdmin;
  final String description;

  LiveGroupDetailsController({
    required this.chatId,
    required this.name,
    required this.avatarColor,
    required this.participantsCount,
    required this.chatMode,
    required this.isAdmin,
    required this.description,
  });

  RxBool isMuted = false.obs;
  RxBool isBanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Default initial mockup switch values
    isMuted.value = name == "Announcements" ? true : false;
  }

  void toggleMuted(bool val) {
    isMuted.value = val;
  }

  void toggleBanned(bool val) {
    isBanned.value = val;
  }
}

// =========================================================================
// 🎨 LIVE GROUP DETAILS SCREEN (MATCHES MOCKUP SCREEN 4)
// =========================================================================
class LiveGroupDetailsScreen extends StatelessWidget {
  const LiveGroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int chatId = args['chat_id'] ?? 15;
    final String name = args['name'] ?? "General Discussion";
    final Color avatarColor = args['avatar_color'] ?? const Color(0xFF0F9D58);
    final int participantsCount = args['participants_count'] ?? 142;
    final String chatMode = args['chat_mode'] ?? "everyone";
    final bool isAdmin = args['is_admin'] ?? true;
    final String description = args['description'] ?? "General chat for all users. Feel free to share your thoughts and ideas.";

    final controller = Get.put(
      LiveGroupDetailsController(
        chatId: chatId,
        name: name,
        avatarColor: avatarColor,
        participantsCount: participantsCount,
        chatMode: chatMode,
        isAdmin: isAdmin,
        description: description,
      ),
      tag: chatId.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black54,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // 👤 Large circular avatar in the center
              Hero(
                tag: 'group-avatar-${controller.chatId}',
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: controller.avatarColor,
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✍️ Group Name Title
              Text(
                controller.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle participants count
              Text(
                "${controller.participantsCount} participants",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Description paragraph matches mockup Screen 4
              Text(
                controller.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.grey[600],
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // 📝 Detail Parameters Card
              _buildDetailsList(controller),
              const SizedBox(height: 16),

              // ⚙️ Switches
              _buildSwitchesList(controller),
              const SizedBox(height: 32),

              // 🏆 Primary view messages green button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Modern active premium minimal black
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "View Messages",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Row lists containing group parameters
  Widget _buildDetailsList(LiveGroupDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
            icon: Icons.person_outline_rounded,
            label: "Created By",
            value: controller.name == "Announcements" ? "Super Admin" : "Admin User",
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.calendar_month_outlined,
            label: "Created At",
            value: "01 May, 2026",
          ),
          _buildDivider(),
          _buildDetailRow(
            icon: Icons.info_outline_rounded,
            label: "Group Status",
            value: "Active",
            valueColor: Colors.green, // Active status
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
          Icon(icon, color: Colors.black45, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
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

  // Row lists containing muted/banned toggles
  Widget _buildSwitchesList(LiveGroupDetailsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Muted toggle row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.volume_off_rounded, color: Colors.black45, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Muted",
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Obx(() => Switch(
                  value: controller.isMuted.value,
                  onChanged: controller.toggleMuted,
                  activeColor: AppColors.primary, // Premium black switch
                )),
              ],
            ),
          ),
          _buildDivider(),
          // Banned toggle row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: Colors.black45, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Banned",
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Obx(() => Switch(
                  value: controller.isBanned.value,
                  onChanged: controller.toggleBanned,
                  activeColor: AppColors.primary, // Premium black switch
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
