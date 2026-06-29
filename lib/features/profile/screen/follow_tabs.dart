import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/features/profile/screen/profile_screen.dart';

import '../../../core/helper/custom_image_view.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/persentation/comming_soon.dart';
import '../../../../core/network/app_urls.dart';
import '../controller/followListController.dart';

// CustomEmptyState widget
class CustomEmptyState extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final bool isSmall;

  const CustomEmptyState({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.icon,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isSmall ? 48 : 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: isSmall ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FollowTabs extends StatelessWidget {
  final int initialTab;
  final int userId;
  FollowTabs({super.key, required this.initialTab, required this.userId});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Connections",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            tabs: const [Tab(text: "Followers"), Tab(text: "Following")],
          ),
        ),
        body: TabBarView(
          children: [
            FollowerList(userId: userId),
            FollowingList(userId: userId),
          ],
        ),
      ),
    );
  }
}

class FollowingList extends StatelessWidget {
  final int userId;

  FollowingList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    print("user id : followers "+userId.toString());
   // final controller = Get.put(FollowListController(userId: userId));
    final controller = Get.put(
      FollowListController(userId: userId),
      tag: userId.toString(),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        controller.filterFollowing(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search following...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: Obx(() {
                if (controller.followingsLoading.value &&
                    controller.followingList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.followingList.isEmpty) {
                  return const CustomEmptyState(
                    title: "No Following",
                    subTitle: "You're not following anyone yet",
                    icon: Icons.people_outline_rounded,
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels ==
                        scroll.metrics.maxScrollExtent) {
                      controller.fetchFollowings(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: controller.filteredFollowingList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = controller.filteredFollowingList[index];

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProfileScreen(viewUserName: user.username));
                        },
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                                  ? NetworkImage(AppUrls.getFullImageUrl(user.avatar))
                                  : null,
                              child: (user.avatar == null || user.avatar!.isEmpty)
                                  ? const Icon(Icons.person, size: 26)
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            // Name & Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "@${user.username}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Follow Button
                            if (!user.isAuthUser)
                              GestureDetector(
                                onTap: () {
                                  if (user.isFollowedByAuthUser) {
                                    _showUnfollowBottomSheet(context, user, controller);
                                  } else {
                                    controller.toggleFollowUser(user.id!);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isFollowedByAuthUser ? Colors.grey.shade200 : AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    user.isFollowedByAuthUser ? "Following" : "Follow",
                                    style: TextStyle(
                                      color: user.isFollowedByAuthUser ? Colors.black87 : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowerList extends StatelessWidget {
  final int userId;

  FollowerList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FollowListController(userId: userId),
      tag: userId.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        controller.filterFollowerSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search followers...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: Obx(() {
                if (controller.followersLoading.value &&
                    controller.followerList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.followerList.isEmpty) {
                  return const CustomEmptyState(
                    title: "No Followers",
                    subTitle: "No one is following you yet",
                    icon: Icons.people_outline_rounded,
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels ==
                        scroll.metrics.maxScrollExtent) {
                      controller.fetchFollowers(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.separated(
                    itemCount: controller.filteredFollowerList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = controller.filteredFollowerList[index];

                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProfileScreen(viewUserName: user.username));
                        },
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                                  ? NetworkImage(AppUrls.getFullImageUrl(user.avatar))
                                  : null,
                              child: (user.avatar == null || user.avatar!.isEmpty)
                                  ? const Icon(Icons.person, size: 26)
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            // Name & Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "@${user.username}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Follow Button
                            if (!user.isAuthUser)
                              GestureDetector(
                                onTap: () {
                                  if (user.isFollowedByAuthUser) {
                                    _showUnfollowBottomSheet(context, user, controller);
                                  } else {
                                    controller.toggleFollowUser(user.id!);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isFollowedByAuthUser ? Colors.grey.shade200 : AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    user.isFollowedByAuthUser ? "Following" : "Follow",
                                    style: TextStyle(
                                      color: user.isFollowedByAuthUser ? Colors.black87 : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Unfollow Confirmation Bottom Sheet
void _showUnfollowBottomSheet(BuildContext context, dynamic user, dynamic controller) {
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.only(top: 20, bottom: 20 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                ? NetworkImage(AppUrls.getFullImageUrl(user.avatar))
                : null,
            child: (user.avatar == null || user.avatar!.isEmpty)
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            "Unfollow @${user.username}?",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 32),
          ListTile(
            title: const Center(
              child: Text(
                "Unfollow",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              Get.back();
              controller.toggleFollowUser(user.id!);
            },
          ),
          const Divider(),
          ListTile(
            title: const Center(child: Text("Cancel")),
            onTap: () => Get.back(),
          ),
        ],
      ),
    ),
  );
}



/*class FollowerList extends StatelessWidget {
  const FollowerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: AppColors.backgroundGradient,
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //     backgroundColor: AppColors.transparent,
        //     leading: GestureDetector(
        //       onTap: (){
        //         Navigator.of(context).pop();
        //       },
        //       child: Icon(
        //         Icons.arrow_back_ios_new_rounded,
        //         color: AppColors.black,
        //       ),
        //     ),
        //     title: Text("username "),
        //   ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: AppColors.lightTextSecondary,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  //  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CustomImageView(
                                url:
                                "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sanjana Patil",
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("@sanjana123.SP1245",
                                    style: TextStyle(
                                      color: AppColors.darkText,
                                      fontSize: 14,
                                    ),)
                                ],
                              ),
                            ),

                            Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                    child: Text("Follow",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.bold),),
                                  ),
                                )
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
        ),
      ),
    );
  }
}*/

/*class FollowingList extends StatelessWidget {
  const FollowingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: AppColors.backgroundGradient,
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //     backgroundColor: AppColors.transparent,
        //     leading: GestureDetector(
        //       onTap: (){
        //         Navigator.of(context).pop();
        //       },
        //       child: Icon(
        //         Icons.arrow_back_ios_new_rounded,
        //         color: AppColors.black,
        //       ),
        //     ),
        //     title: Text("username "),
        //   ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: AppColors.lightTextSecondary,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
               Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    shrinkWrap: true,
                  //  physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CustomImageView(
                                    url:
                                    "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sanjana Patil",
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("@sanjana123.SP1245",
                                        style: TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 14,
                                        ),)
                                    ],
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDark,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                      child: Text("Follow",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.bold),),
                                    ),
                                  )
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
        ),
      ),
    );
  }
}*/
