import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/user_search_controller.dart';
import '../../profile/screen/profile_screen.dart';

class UserSearchScreen extends StatelessWidget {
  UserSearchScreen({Key? key}) : super(key: key);

  final UserSearchController controller = Get.put(UserSearchController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.back, color: AppColors.premiumGold, size: 24),
        ),
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: textController,
            autofocus: true,
            onChanged: (val) => controller.searchUsers(val),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(
                color: AppColors.white,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: Obx(() => controller.query.value.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        textController.clear();
                        controller.searchUsers('');
                      },
                      child: const Icon(Icons.clear, color: AppColors.white, size: 20),
                    )
                  : const SizedBox.shrink()),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.query.value.trim().isEmpty) {
          return Center(
            child: Text(
              "Search for users by name or username",
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
          );
        }

        if (controller.users.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Text(
              "No users found.",
              style: TextStyle(color: AppColors.white, fontSize: 14),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return ListTile(
              onTap: () {
                if (user.username != null && user.username!.isNotEmpty) {
                  Get.to(() => ProfileScreen(viewUserName: user.username));
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.transparent,
                backgroundImage: (user.avtar != null && !user.avtar!.contains("ui-avatars.com")) ? CachedNetworkImageProvider(user.avtar!) : null,
                child: (user.avtar == null || user.avtar!.contains("ui-avatars.com")) ? const Icon(CupertinoIcons.person, color: AppColors.white) : null,
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      user.name ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isVerified == true) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ]
                ],
              ),
              subtitle: Text(
                user.username != null ? "@${user.username}" : "",
                style: const TextStyle(color: AppColors.white, fontSize: 13),
              ),
              trailing: user.isAuthUser == true
                  ? const Text("You", style: TextStyle(color: AppColors.white, fontSize: 12))
                  : null,
            );
          },
        );
      }),
    );
  }
}
