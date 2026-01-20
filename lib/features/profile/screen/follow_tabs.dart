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
import '../controller/followListController.dart';

class FollowTabs extends StatelessWidget {
  final int initialTab;
  final int userId;
  FollowTabs({super.key, required this.initialTab, required this.userId});
  @override
  Widget build(BuildContext context) {
    print("userid access from tabs  : ${userId}");
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        initialIndex: initialTab,
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBar(
            backgroundColor: AppColors.transparent,
            title: Text("Connections"),
            bottom: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.darkText,
              indicatorWeight: 2, // line thickness
              indicatorSize: TabBarIndicatorSize.tab,
              // indicatorSize: TabBarIndicatorSize.label,
              // indicator: UnderlineTabIndicator(
              //   borderSide: BorderSide(width: 2, color: Colors.black),
              //   insets: EdgeInsets.symmetric(horizontal: 80), // ⭐ half-half indicator
              // ),
              indicatorColor: Colors.black,
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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            // ---------------- SEARCH BAR ----------------
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
                      onChanged: (value) {
                        print("onchange value = "+value);
                        controller.filterFollowing(value);
                      },
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

            SizedBox(height: 15),

            // ---------------- LIST DATA ----------------
            Expanded(
              child: Obx(() {
                if (controller.followingsLoading.value &&
                    controller.followingList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.followingList.isEmpty) {
                  return const Center(child: Text("No Following Found",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels ==
                        scroll.metrics.maxScrollExtent) {
                      controller.fetchFollowings(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: controller.filteredFollowingList.length,
                    itemBuilder: (context, index) {
                      final user = controller.filteredFollowingList[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: IntrinsicHeight(
                          child: GestureDetector(
                            onTap: () {
                              // if (user.ac == "private" &&
                              //     (user.isFollowedByAuthUser ?? false) == false) {
                              //   CustomSnackBar.showSuccess(
                              //     message: "First Follow User ",
                              //   );
                              //   return;
                              // }
                              Get.to(() => ProfileScreen(viewUserName: user.username,),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ------------- USER IMAGE -------------
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: (user.avatar != null && user.avatar!.isNotEmpty)
                                      ? CustomImageView(
                                    url: user.avatar!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.asset(
                                    AppAssets.imgAppLogo, // ✅ your asset path
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                SizedBox(width: 20),

                                // ------------- USER NAME + USERNAME -------------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${user.username}",
                                        style: TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!user.isAuthUser)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (user.id != null) {
                                          controller.toggleFollowUser(user.id!,);
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryDark,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            user.isFollowedByAuthUser
                                                ? "Following"
                                                : "Follow",
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
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
  //  final controller = Get.put(FollowListController(userId: userId));
    final controller = Get.put(
      FollowListController(userId: userId),
      tag: userId.toString(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            // ---------------- SEARCH BAR ----------------
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
                      onChanged: (value) {
                        print("onchange value = "+value);
                        controller.filterFollowerSearch(value);
                      },
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

            SizedBox(height: 15),

            // ---------------- LIST DATA ----------------
            Expanded(
              child: Obx(() {
                if (controller.followersLoading.value &&
                    controller.followerList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.followingList.isEmpty) {
                  return const Center(child: Text("No Follower Found",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels ==
                        scroll.metrics.maxScrollExtent) {
                      controller.fetchFollowers(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: controller.filteredFollowerList.length,
                    itemBuilder: (context, index) {
                      final user = controller.filteredFollowerList[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: IntrinsicHeight(
                          child: GestureDetector(
                            onTap: (){
                              Get.to(() => ProfileScreen(viewUserName: user.username,),);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ------------- USER IMAGE -------------
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(15),
                                //   child: CustomImageView(
                                //     url:
                                //         user.avatar ??
                                //         "https://dummyimage.com/200x200/cccccc/000000&text=User",
                                //     height: 50,
                                //     width: 50,
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: (user.avatar != null && user.avatar!.isNotEmpty)
                                      ? CustomImageView(
                                    url: user.avatar!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                      : Image.asset(
                                    AppAssets.imgAppLogo, // ✅ your asset path
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                SizedBox(width: 20),

                                // ------------- USER NAME + USERNAME -------------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${user.username}",
                                        style: TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!user.isAuthUser)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        if (user.id != null) {
                                          controller.toggleFollowUser(
                                            user.id!,
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryDark,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            user.isFollowedByAuthUser
                                                ? "Following"
                                                : "Follow",
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
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
