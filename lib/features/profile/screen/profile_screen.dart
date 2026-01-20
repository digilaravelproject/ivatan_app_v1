import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/features/story/persentation/highlightFullScreen.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_image_view.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../../dashboard/controller/create_story_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/controller/navigationController.dart';
import '../../dashboard/controller/settings_controller.dart';
import '../../dashboard/persentation/settings_page.dart';
import '../../messages/controller/chatt_controller.dart';
import '../../story/persentation/storyfullview.dart';
import '../controller/profile_controller.dart';
import 'follow_tabs.dart';
import 'my_post.dart';
import 'my_video_screen.dart';

class ProfileScreen extends StatefulWidget {
  //ProfileScreen({Key? key}) : super(key: key);
  final String? viewUserName; // add this

  ProfileScreen({Key? key, this.viewUserName}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final profileController = Get.find<SettingsController>();
  late final controller;
  final nav = Get.find<DashboardController>();
  int currentStoryId = 0;
  final profileController = Get.put(SettingsController(userName: ""));
  final StoryController storyController = Get.put(StoryController());
  final ChattController chatController = Get.put(ChattController());

  //final HomeController homeController= Get.put(HomeController());

  String? currentUserName = SharedPrefManager().user?.username;
  late String finalUserName;
  bool isOtherProfile = false;

  @override
  void initState() {
    super.initState();
    //  String selected = nav.viewUserName.value;
    String? selected = widget.viewUserName ?? currentUserName;

    // CASE 1: Coming from some other screen → viewUserName is passed
    if (selected != null &&
        selected!.isNotEmpty &&
        selected != currentUserName) {
      isOtherProfile = true;
      finalUserName = selected!;
    } else {
      // CASE 2: Coming from bottom navigation → load own profile
      isOtherProfile = false;
      finalUserName = currentUserName!;
    }

    // NOW CALL API WITH CORRECT USERNAME
    profileController.fetchUserDetails(finalUserName);
    controller = Get.put(ProfileController(finalUserName), tag: finalUserName);
  }

  bool showAllInterests = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: AppColors.gray,
        body: Obx(() {
          final user = profileController.userProfile.value;
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }
          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.gray,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          user?.profilePhotoPath != null && user!.profilePhotoPath!.isNotEmpty
                              ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
                              : "",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              AppAssets.imgAppLogo,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Container(
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  actions: [
                    const Icon(Icons.more_vert, color: Colors.white),
                    SizedBox(width: 12),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 50), // Profile image ke liye space
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                           Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50),
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 50),
                                  const SizedBox(height: 20),
                                  // Name with info icon
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user?.username ?? "",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          _showBioDialog(user?.bio ?? "");
                                        },
                                        child: Image.asset(AppAssets.iButton, height: 18, width: 18),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            user.occupation.toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      user?.bio ?? "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.black,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            (user.postsCount ?? 0).toString(),
                                            style: TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                          Text(
                                            "Post",
                                            style: TextStyle(color: AppColors.gray),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (user.accountPrivacy == "private" &&
                                              (user.is_following ?? false) == false && (user.is_mine ?? false) == false) {
                                            CustomSnackBar.showSuccess(
                                              message: "First Follow User ",
                                            );
                                            return;
                                          }
                                          print(
                                            "userid access from profile  : ${user.id}",
                                          );
                                          Get.to(
                                                () => FollowTabs(
                                              initialTab: 0,
                                              userId: user.id!,
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              (user.followersCount ?? 0).toString(),
                                              style: TextStyle(
                                                color: AppColors.primaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28,
                                              ),
                                            ),
                                            Text(
                                              "Followers",
                                              style: TextStyle(color: AppColors.gray),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (user.accountPrivacy == "private" &&
                                              (user.is_following ?? false) && (user.is_mine ?? false) == false) {
                                            CustomSnackBar.showSuccess(
                                              message: "First Follow User ",
                                            );
                                            return;
                                          }
                                          Get.to(
                                                () => FollowTabs(
                                              initialTab: 1,
                                              userId: user.id!,
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                              (user.followingCount ?? 0).toString(),
                                              style: TextStyle(
                                                color: AppColors.primaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28,
                                              ),
                                            ),
                                            Text(
                                              "Following",
                                              style: TextStyle(color: AppColors.gray),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  isOtherProfile &&
                                      (user.accountPrivacy) == "private" &&
                                      (user.is_following ?? false) == false
                                      ? GestureDetector(
                                    onTap: () {
                                      if (user.id != null) {
                                        profileController.toggleFollowForPostUser(
                                          user.id!,
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryDark,
                                            AppColors.primaryLight.withOpacity(0.8),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        child: Text(
                                          (user.is_following ?? false)
                                              ? "Request"
                                              : "Follow",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Column(
                                    children: [
                                      isOtherProfile
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (user.id != null) {
                                                profileController
                                                    .toggleFollowForPostUser(
                                                  user.id!,
                                                );
                                              }
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primaryDark,
                                                    AppColors.primaryLight
                                                        .withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 5,
                                                ),
                                                child: Text(
                                                  (user.is_following ?? false)
                                                      ? "Following"
                                                      : "Follow",
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.gray,
                                                  AppColors.gray,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                if (user.chat_id != null) {
                                                  Get.toNamed(
                                                    AppRoutes.chattingScreen,
                                                    arguments: user.chat_id,
                                                  );
                                                } else {
                                                  CustomSnackBar.showInfo(message: "Creating chat user id"+user.id.toString());
                                                  final newChatId = await chatController.createSinglePrivateChat(user.id!.toInt());
                                                  CustomSnackBar.showInfo(message: "Creating chat...$newChatId");
                                                  if (newChatId != null) {
                                                    Get.toNamed(
                                                      AppRoutes.chattingScreen,
                                                      arguments: newChatId,
                                                    );
                                                  } else {
                                                    CustomSnackBar.showError(message: "Unable to start chat");
                                                  }
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 5,
                                                ),
                                                child: Text(
                                                  "Message",
                                                  style: TextStyle(
                                                    color: AppColors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              CustomSnackBar.showInfo(message: "Coming Soon....");
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.gray,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 4,
                                                ),
                                                child: Text(
                                                  "Exclusive",
                                                  style: TextStyle(
                                                    color: AppColors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.more_vert),
                                        ],
                                      )
                                          : Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              controller.showPickerOptions();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.gray,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(SettingsScreen());
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primaryDark,
                                                    AppColors.primaryLight
                                                        .withOpacity(0.8),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 25,
                                                  vertical: 5,
                                                ),
                                                child: Text(
                                                  "Edit Profile",
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.gray,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 25,
                                                vertical: 4,
                                              ),
                                              child: Text(
                                                "Trending",
                                                style: TextStyle(
                                                  color: AppColors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.more_vert),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Obx(() {
                                        if (controller.isLoading.value) {
                                          return SizedBox(
                                            height: 80,
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          height: 90,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            itemCount:
                                            controller.highlights.length + 1,
                                            itemBuilder: (context, index) {
                                              if (index == 0) {
                                                return GestureDetector(
                                                  onTap: () {},
                                                  child: _buildAddStory(),
                                                );
                                              }

                                              final storyIndex = index - 1;

                                              if (storyIndex >= controller.highlights.length) {
                                                return SizedBox();
                                              }

                                              final story = controller.highlights[storyIndex];

                                              return GestureDetector(
                                                onTap: () {
                                                  if (story.stories.isEmpty) {
                                                    Get.snackbar(
                                                      "No Highlights",
                                                      "Highlights not added yet.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                    );
                                                    return;
                                                  }
                                                  Get.to(
                                                        () => HighlightScreenStoryViewer(
                                                      stories: story.stories,
                                                      highlightId: story.id,
                                                      initialIndex: 0,
                                                    ),
                                                  );
                                                },
                                                child: _buildStoryItem(
                                                  story.title,
                                                  story.cover_media_url,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Positioned(
                            top: -40,
                            left: MediaQuery.of(context).size.width / 2 - 50,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF2196F3), width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  user?.profilePhotoPath != null && user!.profilePhotoPath!.isNotEmpty
                                      ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
                                      : "",
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      AppAssets.imgAppLogo,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: Container(
              color: AppColors.white,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: false,
                      dividerColor: Colors.grey,
                      labelColor: Colors.blue,
                      unselectedLabelColor: AppColors.black,
                      indicatorColor: Colors.blue,
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue,
                            width: 3,
                          ),
                        ),
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: 12),
                      tabs: [
                        Tab(
                          child: Image.asset("assets/images/category.png"),
                        ),
                        Tab(
                          child: Image.asset(
                            "assets/images/video.png",
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MyPostScreen(username: finalUserName),
                          MyVideoScreen(username: finalUserName),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  // Widget build(BuildContext context) {
  //   return
  //     Container(
  //     child: Scaffold(
  //       backgroundColor: AppColors.gray,
  //       // appBar: AppBar(
  //       //   backgroundColor: AppColors.gray,
  //       //   // leading: GestureDetector(
  //       //   //   onTap: () {
  //       //   //     Get.back();
  //       //   //   },
  //       //   //     child: Icon(Icons.arrow_back_ios_outlined, color: AppColors.white),
  //       //   // ),
  //       //   actions: [Icon(Icons.more_vert, color: AppColors.white)],
  //       // ),
  //       body: Obx(() {
  //         final user = profileController.userProfile.value;
  //         if (user == null) {
  //           return Center(child: CircularProgressIndicator());
  //         }
  //         return Column(
  //           children: [
  //             /// 🔹 TOP HEADER IMAGE (NOT FULL SCREEN)
  //             SizedBox(
  //               height: 100,
  //               width: double.infinity,
  //               child: Stack(
  //                 fit: StackFit.expand,
  //                 children: [
  //                   Image.network(
  //                     user?.profilePhotoPath != null && user!.profilePhotoPath!.isNotEmpty
  //                         ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
  //                         : "", // agar empty hai to bhi errorBuilder chalega
  //                     width: 90,
  //                     height: 90,
  //                     fit: BoxFit.cover,
  //                     errorBuilder: (context, error, stackTrace) {
  //                       // fallback asset image
  //                       return Image.asset(
  //                         AppAssets.imgAppLogo, // yaha apni asset image ka path
  //                         width: 90,
  //                         height: 90,
  //                         fit: BoxFit.cover,
  //                       );
  //                     },
  //                   ),
  //                   BackdropFilter(
  //                     filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
  //                     child: Container(
  //                       color: Colors.black.withOpacity(0.2),
  //                     ),
  //                   ),
  //
  //                   /// 🔹 Back & Menu buttons
  //                   SafeArea(
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 12),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           IconButton(
  //                             icon: const Icon(Icons.arrow_back,
  //                                 color: Colors.white),
  //                             onPressed: () => Get.back(),
  //                           ),
  //                           const Icon(Icons.more_vert, color: Colors.white),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //            // SizedBox(height: 40),
  //             Expanded(
  //               child: Stack(
  //                 clipBehavior: Clip.none,
  //                 children: [
  //                   Positioned.fill(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: AppColors.white,
  //                         borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(50),
  //                           topRight: Radius.circular(50),
  //                         ),
  //                       ),
  //                       child: Column(
  //                         children: [
  //                           SizedBox(height: 45),
  //                           const SizedBox(height: 20),
  //                           // Name with info icon
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 user?.username ?? "",
  //                                 //  'Leona Manos',
  //                                 style: TextStyle(
  //                                   fontSize: 26,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: AppColors.black,
  //                                   letterSpacing: 0.5,
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 6),
  //                               GestureDetector(
  //                                 onTap: (){
  //                                   _showBioDialog(user?.bio ?? "");
  //                                 },
  //                                   child: Image.asset(AppAssets.iButton,height: 18,width: 18,))
  //                             ],
  //                           ),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               // if (user?.interests != null && user!.interests!.isNotEmpty)
  //                               //   ..._buildInterestList(user!.interests!),
  //
  //                             //  if (user!.interests!.length > 3)
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     // setState(() {
  //                                     //   showAllInterests = !showAllInterests;
  //                                     // });
  //                                   },
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.only(top: 4),
  //                                     child: Text(
  //                                       user.occupation.toString(),
  //                                       style: TextStyle(
  //                                         color: Colors.black,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 14,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                             ],
  //                           ),
  //
  //                         //  const SizedBox(height: 10),
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(horizontal: 40),
  //                             child: Text(
  //                               user?.bio ?? "",
  //                               textAlign: TextAlign.center,
  //                               style: const TextStyle(
  //                                 fontSize: 16,
  //                                 color: AppColors.black,
  //                                 height: 1.5,
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(height: 10),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                             children: [
  //                               Column(
  //                                 children: [
  //                                   Text(
  //                                     (user.postsCount ?? 0).toString(),
  //                                     style: TextStyle(
  //                                       color: AppColors.primaryDark,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 28,
  //                                     ),
  //                                   ),
  //                                   Text(
  //                                     "Post",
  //                                     style: TextStyle(color: AppColors.gray),
  //                                   ),
  //                                 ],
  //                               ),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   if (user.accountPrivacy == "private" &&
  //                                       (user.is_following ?? false) == false && (user.is_mine ?? false) == false) {
  //                                     CustomSnackBar.showSuccess(
  //                                       message: "First Follow User ",
  //                                     );
  //                                     return;
  //                                   }
  //                                   print(
  //                                     "userid access from profile  : ${user.id}",
  //                                   );
  //                                   Get.to(
  //                                     () => FollowTabs(
  //                                       initialTab: 0,
  //                                       userId: user.id!,
  //                                     ),
  //                                   );
  //                                 },
  //                                 child: Column(
  //                                   children: [
  //                                     Text(
  //                                       (user.followersCount ?? 0).toString(),
  //                                       style: TextStyle(
  //                                         color: AppColors.primaryDark,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 28,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       "Followers",
  //                                       style: TextStyle(color: AppColors.gray),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   if (user.accountPrivacy == "private" &&
  //                                       (user.is_following ?? false) && (user.is_mine ?? false) == false) {
  //                                     CustomSnackBar.showSuccess(
  //                                       message: "First Follow User ",
  //                                     );
  //                                     return;
  //                                   }
  //                                   Get.to(
  //                                     () => FollowTabs(
  //                                       initialTab: 1,
  //                                       userId: user.id!,
  //                                     ),
  //                                   );
  //                                 },
  //                                 child: Column(
  //                                   children: [
  //                                     Text(
  //                                       (user.followingCount ?? 0).toString(),
  //                                       style: TextStyle(
  //                                         color: AppColors.primaryDark,
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 28,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       "Following",
  //                                       style: TextStyle(color: AppColors.gray),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(height: 10),
  //                           isOtherProfile &&
  //                                   (user.accountPrivacy) == "private" &&
  //                                   (user.is_following ?? false) == false
  //                               ? GestureDetector(
  //                                 onTap: () {
  //                                   if (user.id != null) {
  //                                     profileController.toggleFollowForPostUser(
  //                                       user.id!,
  //                                     );
  //                                   }
  //                                 },
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       colors: [
  //                                         AppColors.primaryDark,
  //                                         AppColors.primaryLight.withOpacity(0.8),
  //                                       ],
  //                                       begin: Alignment.topCenter,
  //                                       end: Alignment.bottomCenter,
  //                                     ),
  //                                     borderRadius: BorderRadius.only(
  //                                       topLeft: Radius.circular(10),
  //                                       topRight: Radius.circular(10),
  //                                       bottomLeft: Radius.circular(10),
  //                                       bottomRight: Radius.circular(10),
  //                                     ),
  //                                   ),
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.symmetric(
  //                                       horizontal: 15,
  //                                       vertical: 5,
  //                                     ),
  //                                     child: Text(
  //                                       (user.is_following ?? false)
  //                                           ? "Request"
  //                                           : "Follow",
  //                                       style: TextStyle(
  //                                         color: AppColors.white,
  //                                         fontSize: 18,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               )
  //                               : Flexible(
  //                                 child: Column(
  //                                   children: [
  //                                     isOtherProfile
  //                                         ? Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.spaceEvenly,
  //                                           children: [
  //                                             GestureDetector(
  //                                               onTap: () {
  //                                                 if (user.id != null) {
  //                                                   profileController
  //                                                       .toggleFollowForPostUser(
  //                                                         user.id!,
  //                                                       );
  //                                                 }
  //                                               },
  //                                               child: Container(
  //                                                 decoration: BoxDecoration(
  //                                                   gradient: LinearGradient(
  //                                                     colors: [
  //                                                       AppColors.primaryDark,
  //                                                       AppColors.primaryLight
  //                                                           .withOpacity(0.8),
  //                                                     ],
  //                                                     begin: Alignment.topCenter,
  //                                                     end: Alignment.bottomCenter,
  //                                                   ),
  //                                                   borderRadius:
  //                                                       BorderRadius.only(
  //                                                         topLeft:
  //                                                             Radius.circular(10),
  //                                                         topRight:
  //                                                             Radius.circular(10),
  //                                                         bottomLeft:
  //                                                             Radius.circular(10),
  //                                                         bottomRight:
  //                                                             Radius.circular(10),
  //                                                       ),
  //                                                 ),
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.symmetric(
  //                                                         horizontal: 15,
  //                                                         vertical: 5,
  //                                                       ),
  //                                                   child: Text(
  //                                                     (user.is_following ?? false)
  //                                                         ? "Following"
  //                                                         : "Follow",
  //                                                     style: TextStyle(
  //                                                       color: AppColors.white,
  //                                                       fontSize: 18,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             Container(
  //                                               decoration: BoxDecoration(
  //                                                 gradient: LinearGradient(
  //                                                   colors: [
  //                                                     AppColors.gray,
  //                                                     AppColors.gray,
  //                                                   ],
  //                                                   begin: Alignment.topCenter,
  //                                                   end: Alignment.bottomCenter,
  //                                                 ),
  //                                                 borderRadius: BorderRadius.only(
  //                                                   topLeft: Radius.circular(10),
  //                                                   topRight: Radius.circular(10),
  //                                                   bottomLeft: Radius.circular(
  //                                                     10,
  //                                                   ),
  //                                                   bottomRight: Radius.circular(
  //                                                     10,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               child: InkWell(
  //                                                 onTap: () {
  //                                                   CustomSnackBar.showInfo(message: "Coming Soon....");
  //                                                   Get.toNamed(
  //                                                     AppRoutes.chattingScreen,
  //                                                     arguments: user.chat_id,
  //                                                   );
  //                                                 },
  //                                                 onTap: () async {
  //                                                   if (user.chat_id != null) {
  //
  //                                                     Get.toNamed(
  //                                                       AppRoutes.chattingScreen,
  //                                                       arguments: user.chat_id,
  //                                                     );
  //                                                   } else {
  //                                                     CustomSnackBar.showInfo(message: "Creating chat user id"+user.id.toString());
  //                                                     final newChatId = await chatController.createSinglePrivateChat(user.id!.toInt());
  //                                                     CustomSnackBar.showInfo(message: "Creating chat...$newChatId");
  //                                                     if (newChatId != null) {
  //                                                       Get.toNamed(
  //                                                         AppRoutes.chattingScreen,
  //                                                         arguments: newChatId,
  //                                                       );
  //                                                     } else {
  //                                                       CustomSnackBar.showError(message: "Unable to start chat");
  //                                                     }
  //                                                   }
  //                                                 },
  //
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.symmetric(
  //                                                         horizontal: 15,
  //                                                         vertical: 5,
  //                                                       ),
  //                                                   child: Text(
  //                                                     "Message",
  //                                                     style: TextStyle(
  //                                                       color: AppColors.black,
  //                                                       fontSize: 18,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             InkWell(
  //                                               onTap: (){
  //                                                 CustomSnackBar.showInfo(message: "Coming Soon....");
  //                                               },
  //                                               child: Container(
  //                                                 decoration: BoxDecoration(
  //                                                   border: Border.all(
  //                                                     color: AppColors.gray,
  //                                                     width: 1,
  //                                                   ),
  //                                                   borderRadius: BorderRadius.only(
  //                                                     topLeft: Radius.circular(10),
  //                                                     topRight: Radius.circular(10),
  //                                                     bottomLeft: Radius.circular(
  //                                                       10,
  //                                                     ),
  //                                                     bottomRight: Radius.circular(
  //                                                       10,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.symmetric(
  //                                                         horizontal: 15,
  //                                                         vertical: 4,
  //                                                       ),
  //                                                   child: Text(
  //                                                     "Exclusive",
  //                                                     style: TextStyle(
  //                                                       color: AppColors.black,
  //                                                       fontSize: 18,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             Icon(Icons.more_vert),
  //                                           ],
  //                                         )
  //                                         : Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.spaceEvenly,
  //                                           children: [
  //                                             GestureDetector(
  //                                               onTap: () {
  //                                                 controller.showPickerOptions();
  //                                               },
  //                                               child: Container(
  //                                                 width: 40,
  //                                                 height: 40,
  //                                                 decoration: BoxDecoration(
  //                                                   color: AppColors.gray,
  //                                                   shape: BoxShape.circle,
  //                                                   //    border: Border.all(color: Colors.grey.shade300, width: 2),
  //                                                 ),
  //                                                 child: Icon(
  //                                                   Icons.add,
  //                                                   color: Colors.grey[700],
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             GestureDetector(
  //                                               onTap: () {
  //                                                 Get.to(SettingsScreen());
  //                                               },
  //                                               child: Container(
  //                                                 decoration: BoxDecoration(
  //                                                   gradient: LinearGradient(
  //                                                     colors: [
  //                                                       AppColors.primaryDark,
  //                                                       AppColors.primaryLight
  //                                                           .withOpacity(0.8),
  //                                                     ],
  //                                                     begin: Alignment.topCenter,
  //                                                     end: Alignment.bottomCenter,
  //                                                   ),
  //                                                   borderRadius:
  //                                                       BorderRadius.only(
  //                                                         topLeft:
  //                                                             Radius.circular(10),
  //                                                         topRight:
  //                                                             Radius.circular(10),
  //                                                         bottomLeft:
  //                                                             Radius.circular(10),
  //                                                         bottomRight:
  //                                                             Radius.circular(10),
  //                                                       ),
  //                                                 ),
  //                                                 child: Padding(
  //                                                   padding:
  //                                                       const EdgeInsets.symmetric(
  //                                                         horizontal: 25,
  //                                                         vertical: 5,
  //                                                       ),
  //                                                   child: Text(
  //                                                     "Edit Profile",
  //                                                     style: TextStyle(
  //                                                       color: AppColors.white,
  //                                                       fontSize: 18,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             Container(
  //                                               decoration: BoxDecoration(
  //                                                 border: Border.all(
  //                                                   color: AppColors.gray,
  //                                                   width: 1,
  //                                                 ),
  //                                                 borderRadius: BorderRadius.only(
  //                                                   topLeft: Radius.circular(10),
  //                                                   topRight: Radius.circular(10),
  //                                                   bottomLeft: Radius.circular(
  //                                                     10,
  //                                                   ),
  //                                                   bottomRight: Radius.circular(
  //                                                     10,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               child: Padding(
  //                                                 padding:
  //                                                     const EdgeInsets.symmetric(
  //                                                       horizontal: 25,
  //                                                       vertical: 4,
  //                                                     ),
  //                                                 child: Text(
  //                                                   "Trending",
  //                                                   style: TextStyle(
  //                                                     color: AppColors.black,
  //                                                     fontSize: 18,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             Icon(Icons.more_vert),
  //                                           ],
  //                                         ),
  //                                     SizedBox(height: 10),
  //
  //                                     Obx(() {
  //                                       if (controller.isLoading.value) {
  //                                         return SizedBox(
  //                                           height: 80,
  //                                           child: Center(
  //                                             child: CircularProgressIndicator(),
  //                                           ),
  //                                         );
  //                                       }
  //                                       return SizedBox(
  //                                         height: 90,
  //                                         child: ListView.builder(
  //                                           scrollDirection: Axis.horizontal,
  //                                           padding: const EdgeInsets.symmetric(
  //                                             horizontal: 16,
  //                                           ),
  //                                           itemCount:
  //                                           controller.highlights.length + 1,
  //                                           itemBuilder: (context, index) {
  //                                             // Add Story Button
  //                                             if (index == 0) {
  //                                               return GestureDetector(
  //                                                 onTap: () {
  //                                                   // Get.to(() => FullScreenStoryViewer(
  //                                                   //   stories: controller.storyData,   // list jo aap pass karoge
  //                                                   //   initialIndex: index,      // kis story se start karni
  //                                                   // ));
  //                                                 //  storyController.showPickerOptions();
  //                                                 },
  //
  //                                                 child: _buildAddStory(),
  //                                               );
  //                                             }
  //
  //                                             // Story item
  //                                             final storyIndex = index - 1;
  //
  //                                             if (storyIndex >= controller.highlights.length) {
  //                                               return SizedBox(); // Safety
  //                                             }
  //
  //                                             final story = controller.highlights[storyIndex];
  //
  //                                             return GestureDetector(
  //                                               onTap: () {
  //                                                 if (story.stories.isEmpty) {
  //                                                   Get.snackbar(
  //                                                     "No Highlights",
  //                                                     "Highlights not added yet.",
  //                                                     snackPosition: SnackPosition.BOTTOM,
  //                                                   );
  //                                                   return;
  //                                                 }
  //                                                 Get.to(
  //                                                   () => HighlightScreenStoryViewer(
  //                                                     stories: story.stories,
  //                                                     highlightId: story.id,
  //                                                     initialIndex: 0,
  //                                                   ),
  //                                                 );
  //                                               },
  //                                               child: _buildStoryItem(
  //                                                 story.title,
  //                                                 story.cover_media_url,
  //                                               ),
  //                                             );
  //                                           },
  //                                         ),
  //                                       );
  //                                     }),
  //                                     Expanded(
  //                                       child: DefaultTabController(
  //                                         length: 2,
  //                                         child: Column(
  //                                           children: [
  //                                             TabBar(
  //                                               isScrollable: false,
  //                                               dividerColor: Colors.grey,
  //                                               labelColor: Colors.blue,
  //                                               unselectedLabelColor:
  //                                                   AppColors.black,
  //                                               indicatorColor: Colors.blue,
  //                                               indicator: BoxDecoration(
  //                                                 border: Border(
  //                                                   bottom: BorderSide(
  //                                                     color: Colors.blue,
  //                                                     width: 3,
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                               labelPadding:
  //                                                   EdgeInsets.symmetric(
  //                                                     horizontal: 12,
  //                                                   ),
  //                                               tabs: [
  //                                                 Tab(
  //                                                   child: Image.asset(
  //                                                     "assets/images/category.png",
  //                                                   ),
  //                                                 ),
  //                                                 Tab(
  //                                                   child: Image.asset(
  //                                                     "assets/images/video.png",
  //                                                     height: 24,
  //                                                     width: 24,
  //                                                   ),
  //                                                 ),
  //                                                 Tab(
  //                                                   child: Image.asset(
  //                                                     "assets/images/product.png",
  //                                                     height: 40,
  //                                                     width: 40,
  //                                                   ),
  //                                                 ),
  //                                                 Tab(
  //                                                   child: Image.asset(
  //                                                     "assets/images/scale.png",
  //                                                     height: 40,
  //                                                     width: 40,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //
  //                                             Expanded(
  //                                               child: TabBarView(
  //                                                 children: [
  //                                                   MyPostScreen(
  //                                                     username: finalUserName,
  //                                                   ),
  //                                                   MyVideoScreen(
  //                                                     username: finalUserName,
  //                                                   ),
  //                                                   Center(child: Text("data")),
  //                                                   Center(child: Text("data")),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     top: -40,
  //                     // left: 0,
  //                     // right: 0,
  //                     left: MediaQuery.of(context).size.width / 2 - 50,
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         border: Border.all(color: Color(0xFF2196F3), width: 4),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.black.withOpacity(0.15),
  //                             blurRadius: 20,
  //                             offset: Offset(0, 8),
  //                           ),
  //                         ],
  //                       ),
  //                       child: ClipOval(
  //                         child:Image.network(
  //                           user?.profilePhotoPath != null && user!.profilePhotoPath!.isNotEmpty
  //                               ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
  //                               : "", // agar empty hai to bhi errorBuilder chalega
  //                           width: 90,
  //                           height: 90,
  //                           fit: BoxFit.cover,
  //                           errorBuilder: (context, error, stackTrace) {
  //                             // fallback asset image
  //                             return Image.asset(
  //                              AppAssets.imgAppLogo, // yaha apni asset image ka path
  //                               width: 90,
  //                               height: 90,
  //                               fit: BoxFit.cover,
  //                             );
  //                           },
  //                         ),
  //
  //
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       }),
  //     ),
  //   );
  // }

  void _showBioDialog(String bio) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Bio text
              Text(
                bio.isNotEmpty ? bio : "No bio available",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }


  List<Widget> _buildInterestList(List<String> interests) {
    List<String> visibleList =
        showAllInterests ? interests : interests.take(3).toList();

    return visibleList.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          item,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.gray,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }

  Widget _buildAddStory() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              //    border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'New',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              //   border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl.isNotEmpty
                    ? imageUrl
                    : "https://cloudinary-marketing-res.cloudinary.com/image/upload/w_700/hiking_dog_mountain",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    "https://cloudinary-marketing-res.cloudinary.com/image/upload/w_700/hiking_dog_mountain",
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}




//   Obx(() {
//   final user = profileController.userProfile.value;
//   if (user == null) {
//     return Center(child: CircularProgressIndicator());
//   }
//   return Stack(
//     children: [
//       Positioned.fill(
//         child: Image.network(
//           user?.profilePhotoPath != null &&
//                   user!.profilePhotoPath!.isNotEmpty
//               ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
//               : "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
//         //  height: 200, width: 300,
//         ),
//       ),
//
//       /// 🔹 HALF BLUR HEADER (Expanded-like)
//       Align(
//         alignment: Alignment.topCenter,
//         child: FractionallySizedBox(
//         //  heightFactor: 0.35, // 👈 adjust (30–40%)
//           widthFactor: 1,
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//             child: Container(color: Colors.white.withOpacity(0.1)),
//           ),
//         ),
//       ),
//
//       Column(
//         children: [
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Get.back(),
//                   ),
//                   const Icon(Icons.more_vert, color: Colors.white),
//                 ],
//               ),
//             ),
//           ),
//           //  const SizedBox(height: 120),
//           Expanded(
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(50),
//                         topRight: Radius.circular(50),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         SizedBox(height: 45),
//                         const SizedBox(height: 20),
//                         // Name with info icon
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               user?.username ?? "",
//                               //  'Leona Manos',
//                               style: TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.black,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Container(
//                               padding: const EdgeInsets.all(3),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[600],
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.info,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // if (user?.interests != null && user!.interests!.isNotEmpty)
//                             //   ..._buildInterestList(user!.interests!),
//
//                             //  if (user!.interests!.length > 3)
//                             GestureDetector(
//                               onTap: () {
//                                 // setState(() {
//                                 //   showAllInterests = !showAllInterests;
//                                 // });
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   user.occupation.toString(),
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         /*   Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(
//                               Icons.location_on,
//                               size: 18,
//                               color: Color(0xFF9E9E9E),
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Mumbai, Maharashtra',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: AppColors.black,
//                               ),
//                             ),
//                           ],
//                         ),*/
//                         //  const SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 40,
//                           ),
//                           child: Text(
//                             user?.bio ?? "",
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: AppColors.black,
//                               height: 1.5,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               children: [
//                                 Text(
//                                   (user.postsCount ?? 0).toString(),
//                                   style: TextStyle(
//                                     color: AppColors.primaryDark,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 28,
//                                   ),
//                                 ),
//                                 Text(
//                                   "Post",
//                                   style: TextStyle(color: AppColors.gray),
//                                 ),
//                               ],
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 if (user.accountPrivacy == "private" &&
//                                     (user.is_following ?? false) == false &&
//                                     (user.is_mine ?? false) == false) {
//                                   CustomSnackBar.showSuccess(
//                                     message: "First Follow User ",
//                                   );
//                                   return;
//                                 }
//                                 print(
//                                   "userid access from profile  : ${user.id}",
//                                 );
//                                 Get.to(
//                                       () => FollowTabs(
//                                     initialTab: 0,
//                                     userId: user.id!,
//                                   ),
//                                 );
//                               },
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     (user.followersCount ?? 0).toString(),
//                                     style: TextStyle(
//                                       color: AppColors.primaryDark,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 28,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Followers",
//                                     style: TextStyle(color: AppColors.gray),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 if (user.accountPrivacy == "private" &&
//                                     (user.is_following ?? false) &&
//                                     (user.is_mine ?? false) == false) {
//                                   CustomSnackBar.showSuccess(
//                                     message: "First Follow User ",
//                                   );
//                                   return;
//                                 }
//                                 Get.to(
//                                       () => FollowTabs(
//                                     initialTab: 1,
//                                     userId: user.id!,
//                                   ),
//                                 );
//                               },
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     (user.followingCount ?? 0).toString(),
//                                     style: TextStyle(
//                                       color: AppColors.primaryDark,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 28,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Following",
//                                     style: TextStyle(color: AppColors.gray),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         isOtherProfile &&
//                             (user.accountPrivacy) == "private" &&
//                             (user.is_following ?? false) == false
//                             ? GestureDetector(
//                           onTap: () {
//                             if (user.id != null) {
//                               profileController.toggleFollowForPostUser(
//                                 user.id!,
//                               );
//                             }
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppColors.primaryDark,
//                                   AppColors.primaryLight.withOpacity(
//                                     0.8,
//                                   ),
//                                 ],
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                               ),
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(10),
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10),
//                               ),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 15,
//                                 vertical: 5,
//                               ),
//                               child: Text(
//                                 (user.is_following ?? false)
//                                     ? "Request"
//                                     : "Follow",
//                                 style: TextStyle(
//                                   color: AppColors.white,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                             : Flexible(
//                           child: Column(
//                             children: [
//                               isOtherProfile
//                                   ? Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       if (user.id != null) {
//                                         profileController
//                                             .toggleFollowForPostUser(
//                                           user.id!,
//                                         );
//                                       }
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             AppColors.primaryDark,
//                                             AppColors.primaryLight
//                                                 .withOpacity(0.8),
//                                           ],
//                                           begin:
//                                           Alignment.topCenter,
//                                           end:
//                                           Alignment
//                                               .bottomCenter,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.only(
//                                           topLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           topRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                           horizontal: 15,
//                                           vertical: 5,
//                                         ),
//                                         child: Text(
//                                           (user.is_following ??
//                                               false)
//                                               ? "Following"
//                                               : "Follow",
//                                           style: TextStyle(
//                                             color: AppColors.white,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         colors: [
//                                           AppColors.gray,
//                                           AppColors.gray,
//                                         ],
//                                         begin: Alignment.topCenter,
//                                         end: Alignment.bottomCenter,
//                                       ),
//                                       borderRadius:
//                                       BorderRadius.only(
//                                         topLeft:
//                                         Radius.circular(10),
//                                         topRight:
//                                         Radius.circular(10),
//                                         bottomLeft:
//                                         Radius.circular(10),
//                                         bottomRight:
//                                         Radius.circular(10),
//                                       ),
//                                     ),
//                                     child: InkWell(
//                                       /*onTap: () {
//                                                 CustomSnackBar.showInfo(message: "Coming Soon....");
//                                                 Get.toNamed(
//                                                   AppRoutes.chattingScreen,
//                                                   arguments: user.chat_id,
//                                                 );
//                                               },*/
//                                       onTap: () async {
//                                         if (user.chat_id != null) {
//                                           Get.toNamed(
//                                             AppRoutes
//                                                 .chattingScreen,
//                                             arguments: user.chat_id,
//                                           );
//                                         } else {
//                                           CustomSnackBar.showInfo(
//                                             message:
//                                             "Creating chat user id" +
//                                                 user.id.toString(),
//                                           );
//                                           final newChatId =
//                                           await chatController
//                                               .createSinglePrivateChat(
//                                             user.id!
//                                                 .toInt(),
//                                           );
//                                           CustomSnackBar.showInfo(
//                                             message:
//                                             "Creating chat...$newChatId",
//                                           );
//                                           if (newChatId != null) {
//                                             Get.toNamed(
//                                               AppRoutes
//                                                   .chattingScreen,
//                                               arguments: newChatId,
//                                             );
//                                           } else {
//                                             CustomSnackBar.showError(
//                                               message:
//                                               "Unable to start chat",
//                                             );
//                                           }
//                                         }
//                                       },
//
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                           horizontal: 15,
//                                           vertical: 5,
//                                         ),
//                                         child: Text(
//                                           "Message",
//                                           style: TextStyle(
//                                             color: AppColors.black,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     onTap: () {
//                                       CustomSnackBar.showInfo(
//                                         message: "Coming Soon....",
//                                       );
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                           color: AppColors.gray,
//                                           width: 1,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.only(
//                                           topLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           topRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                           horizontal: 15,
//                                           vertical: 4,
//                                         ),
//                                         child: Text(
//                                           "Exclusive",
//                                           style: TextStyle(
//                                             color: AppColors.black,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Icon(Icons.more_vert),
//                                 ],
//                               )
//                                   : Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceEvenly,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       controller
//                                           .showPickerOptions();
//                                     },
//                                     child: Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         color: AppColors.gray,
//                                         shape: BoxShape.circle,
//                                         //    border: Border.all(color: Colors.grey.shade300, width: 2),
//                                       ),
//                                       child: Icon(
//                                         Icons.add,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Get.to(SettingsScreen());
//                                     },
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             AppColors.primaryDark,
//                                             AppColors.primaryLight
//                                                 .withOpacity(0.8),
//                                           ],
//                                           begin:
//                                           Alignment.topCenter,
//                                           end:
//                                           Alignment
//                                               .bottomCenter,
//                                         ),
//                                         borderRadius:
//                                         BorderRadius.only(
//                                           topLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           topRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomLeft:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                           bottomRight:
//                                           Radius.circular(
//                                             10,
//                                           ),
//                                         ),
//                                       ),
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                           horizontal: 25,
//                                           vertical: 5,
//                                         ),
//                                         child: Text(
//                                           "Edit Profile",
//                                           style: TextStyle(
//                                             color: AppColors.white,
//                                             fontSize: 18,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: AppColors.gray,
//                                         width: 1,
//                                       ),
//                                       borderRadius:
//                                       BorderRadius.only(
//                                         topLeft:
//                                         Radius.circular(10),
//                                         topRight:
//                                         Radius.circular(10),
//                                         bottomLeft:
//                                         Radius.circular(10),
//                                         bottomRight:
//                                         Radius.circular(10),
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding:
//                                       const EdgeInsets.symmetric(
//                                         horizontal: 25,
//                                         vertical: 4,
//                                       ),
//                                       child: Text(
//                                         "Trending",
//                                         style: TextStyle(
//                                           color: AppColors.black,
//                                           fontSize: 18,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Icon(Icons.more_vert),
//                                 ],
//                               ),
//                               SizedBox(height: 10),
//
//                               Obx(() {
//                                 if (controller.isLoading.value) {
//                                   return SizedBox(
//                                     height: 80,
//                                     child: Center(
//                                       child:
//                                       CircularProgressIndicator(),
//                                     ),
//                                   );
//                                 }
//                                 return SizedBox(
//                                   height: 90,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                     ),
//                                     itemCount:
//                                     controller.highlights.length +
//                                         1,
//                                     itemBuilder: (context, index) {
//                                       // Add Story Button
//                                       if (index == 0) {
//                                         return GestureDetector(
//                                           onTap: () {
//                                             // Get.to(() => FullScreenStoryViewer(
//                                             //   stories: controller.storyData,   // list jo aap pass karoge
//                                             //   initialIndex: index,      // kis story se start karni
//                                             // ));
//                                             //  storyController.showPickerOptions();
//                                           },
//
//                                           child: _buildAddStory(),
//                                         );
//                                       }
//
//                                       // Story item
//                                       final storyIndex = index - 1;
//
//                                       if (storyIndex >=
//                                           controller
//                                               .highlights
//                                               .length) {
//                                         return SizedBox(); // Safety
//                                       }
//
//                                       final story =
//                                       controller
//                                           .highlights[storyIndex];
//
//                                       return GestureDetector(
//                                         onTap: () {
//                                           if (story.stories.isEmpty) {
//                                             Get.snackbar(
//                                               "No Highlights",
//                                               "Highlights not added yet.",
//                                               snackPosition:
//                                               SnackPosition.BOTTOM,
//                                             );
//                                             return;
//                                           }
//                                           Get.to(
//                                                 () =>
//                                                 HighlightScreenStoryViewer(
//                                                   stories:
//                                                   story.stories,
//                                                   highlightId: story.id,
//                                                   initialIndex: 0,
//                                                 ),
//                                           );
//                                         },
//                                         child: _buildStoryItem(
//                                           story.title,
//                                           story.cover_media_url,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               }),
//                               Expanded(
//                                 child: DefaultTabController(
//                                   length: 2,
//                                   child: Column(
//                                     children: [
//                                       TabBar(
//                                         isScrollable: false,
//                                         dividerColor: Colors.grey,
//                                         labelColor: Colors.blue,
//                                         unselectedLabelColor:
//                                         AppColors.black,
//                                         indicatorColor: Colors.blue,
//                                         indicator: BoxDecoration(
//                                           border: Border(
//                                             bottom: BorderSide(
//                                               color: Colors.blue,
//                                               width: 3,
//                                             ),
//                                           ),
//                                         ),
//                                         labelPadding:
//                                         EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                         ),
//                                         tabs: [
//                                           Tab(
//                                             child: Image.asset(
//                                               "assets/images/category.png",
//                                             ),
//                                           ),
//                                           Tab(
//                                             child: Image.asset(
//                                               "assets/images/video.png",
//                                               height: 24,
//                                               width: 24,
//                                             ),
//                                           ),
//                                           /*Tab(
//                                                 child: Image.asset(
//                                                   "assets/images/product.png",
//                                                   height: 40,
//                                                   width: 40,
//                                                 ),
//                                               ),
//                                               Tab(
//                                                 child: Image.asset(
//                                                   "assets/images/scale.png",
//                                                   height: 40,
//                                                   width: 40,
//                                                 ),
//                                               ),*/
//                                         ],
//                                       ),
//
//                                       Expanded(
//                                         child: TabBarView(
//                                           children: [
//                                             MyPostScreen(
//                                               username: finalUserName,
//                                             ),
//                                             MyVideoScreen(
//                                               username: finalUserName,
//                                             ),
//                                             /*Center(child: Text("data")),
//                                                 Center(child: Text("data")),*/
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         /*SizedBox(
//                           height: 90,
//                           child: ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             itemCount: 10,
//                             itemBuilder: (context, index) {
//                               if (index == 0) {
//                                 return _buildAddStory();
//                               }
//                               return _buildStoryItem(
//                                 "Awantika",
//                                 // story.user.avatar.isNotEmpty
//                                 "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp", // fallback
//                               );
//                             },
//                           ),
//                         ),*/
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: -40,
//                   // left: 0,
//                   // right: 0,
//                   left: MediaQuery.of(context).size.width / 2 - 50,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Color(0xFF2196F3),
//                         width: 4,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 20,
//                           offset: Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: ClipOval(
//                       child: Image.network(
//                         user?.profilePhotoPath != null &&
//                             user!.profilePhotoPath!.isNotEmpty
//                             ? "${AppUrls.imageurl}${user!.profilePhotoPath}"
//                             : "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
//                         width: 90,
//                         height: 90,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// });