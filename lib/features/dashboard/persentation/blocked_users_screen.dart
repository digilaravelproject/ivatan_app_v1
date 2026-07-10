import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/blocked_users_controller.dart';
import '../../../core/theme/app_colors.dart';

class BlockedUsersScreen extends StatelessWidget {
  BlockedUsersScreen({Key? key}) : super(key: key);

  final BlockedUsersController controller = Get.put(BlockedUsersController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        controller.fetchBlockedUsers(loadMore: true);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                    ]),
                child: const Icon(CupertinoIcons.back, color: Colors.black, size: 20))),
        title: const Text("Blocked Accounts",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.blockedUsers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.blockedUsers.isEmpty) {
          return const Center(
            child: Text(
              "No blocked users.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBlockedUsers(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.blockedUsers.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.blockedUsers.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final user = controller.blockedUsers[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                      child: user.avatar == null ? const Icon(CupertinoIcons.person, color: Colors.grey) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name ?? "Unknown",
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (user.isVerified == true) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@${user.username ?? ''}",
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                          if (user.blockedHuman != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Blocked ${user.blockedHuman}",
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (user.id != null) {
                          controller.unblockUser(user.id!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Unblock",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
