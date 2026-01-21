import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/features/story/persentation/highlightFullScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_image_view.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/helper/extensions.dart';
import '../../../core/network/app_urls.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../route/app_pages.dart';
import '../../dashboard/controller/create_story_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/controller/navigationController.dart';
import '../../dashboard/controller/settings_controller.dart';
import '../../dashboard/model/user_profile.dart';
import '../../dashboard/persentation/comming_soon.dart';
import '../../dashboard/persentation/post_media_picker_screen.dart';
import '../../dashboard/persentation/reel_media_picker_screen.dart';
import '../../dashboard/persentation/settings_page.dart';
import '../../messages/controller/chatt_controller.dart';
import '../../messages/persentation/chatting_screen.dart';
import '../../story/persentation/storyfullview.dart';
import '../controller/profile_controller.dart';
import 'follow_tabs.dart';
import 'my_post.dart';
import 'my_video_screen.dart';
import 'profile_shop_screen.dart';
import 'profile_live_posts.dart';

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
  late SettingsController profileController;
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
      // For other profiles, use a tag with their username
      profileController = Get.put(SettingsController(userName: finalUserName), tag: finalUserName);
    } else {
      // CASE 2: Coming from bottom navigation → load own profile
      isOtherProfile = false;
      finalUserName = currentUserName ?? "";
      // For own profile, use the same tag as used in SettingsPage
      profileController = Get.put(SettingsController(userName: finalUserName), tag: finalUserName);
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
        backgroundColor: AppColors.white,
        body: Obx(() {
          final user = profileController.userProfile.value;
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }
          
          final isFollowing = profileController.followController.isUserFollowing(user.id!).value;
          final bool isPrivateHidden = isOtherProfile && 
                                     user.accountPrivacy == "private" && 
                                     !isFollowing;
          return DefaultTabController(
            length: 4,
            child: Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Cover Image & Info Container
                            Column(
                              children: [
                                // Cover Area
                                Container(
                                  height: 240,
                                  width: double.infinity,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [

                                      Image.network(
                                        user.profilePhotoPath != null && user.profilePhotoPath!.isNotEmpty
                                            ? "${AppUrls.imageurl}${user.profilePhotoPath}"
                                            : "",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Image.asset(AppAssets.imgAppLogo, fit: BoxFit.cover),
                                      ),
                                      ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                          child: Container(color: Colors.black.withOpacity(0.3)),
                                        ),
                                      ),
                                       Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.black54, Colors.transparent, Colors.black54],
                                          ),
                                        ),
                                      ),
                                      // Back Button (Only for other profiles)

                                      if (isOtherProfile)
                                        Positioned(
                                          top: 40,
                                          left: 10,
                                          child: IconButton(
                                            icon: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                            ),
                                            onPressed: () => Get.back(),
                                          ),
                                        ),

                                       // Icons
                                      if (!isOtherProfile)
                                        Positioned(
                                          top: 40,
                                          right: 10,
                                          child: IconButton(
                                            icon: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                              child: const Icon(Icons.settings, color: Colors.white, size: 20),
                                            ),
                                            onPressed: () => Get.to(() => SettingsScreen()),
                                          ),
                                        ),
                                      // Stats Pill
                                      Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: 16,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: Row(
                                            children: [
                                              Text(
                                                  "@${user.username ?? ""}".toTitleCase(),
                                                  style: const TextStyle(color: Colors.white, fontSize: 20)
                                              ),
                                              if (user.isVerified ?? false) ...[
                                                const SizedBox(width: 4),
                                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                                              ]
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 16,
                                        bottom: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white30, width: 0.5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildStatItem("${user.followersCount ?? 0} Followers", user, 0),
                                              Container(width: 1, height: 16, color: Colors.white30),
                                              _buildStatItem("${user.followingCount ?? 0} Following", user, 1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Body Info Container
                                Container(
                                  color: AppColors.white,
                                  padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                  // Name
                                                  Text(
                                                    user.name ?? "User",
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  
                                                  // Username & Verification
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "@${user.username ?? ""}", 
                                                        style: const TextStyle(color: Colors.black54, fontSize: 14)
                                                      ),
                                                      if (user.isVerified ?? false) ...[
                                                        const SizedBox(width: 4),
                                                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                                                      ]
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Occupation pill
                                                  Container(
                                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                     decoration: BoxDecoration(
                                                       color: Colors.grey.shade100,
                                                       borderRadius: BorderRadius.circular(4),
                                                     ),
                                                     child: Text(
                                                        user.occupation?.isNotEmpty == true ? user.occupation! : "Digital Creator",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade800,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // Bio
                                                  if (user.bio != null && user.bio!.isNotEmpty)
                                                    Text(
                                                      user.bio!,
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 3, 
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                              ]
                                            ),
                                          ),

                                          if (!isOtherProfile)
                                            InkWell(
                                              onTap: () {
                                                Get.bottomSheet(
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                                    ),
                                                    padding: const EdgeInsets.only(top: 12, bottom: 30, left: 20, right: 20),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        // Drag Handle
                                                        Container(
                                                          width: 40,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade300,
                                                            borderRadius: BorderRadius.circular(2),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 20),
                                                        const Text("Create New", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                        const SizedBox(height: 25),
                                                        
                                                        // Options
                                                        _buildCreateOption(
                                                          icon: Icons.post_add_rounded,
                                                          color: Colors.blueAccent,
                                                          title: "Post",
                                                          subtitle: "Share a photo or write something",
                                                          onTap: () { 
                                                            Get.back();
                                                            // Square format picker (1:1)
                                                            Get.to(() => const PostMediaPickerScreen());
                                                          },
                                                        ),
                                                        const SizedBox(height: 16),
                                                        _buildCreateOption(
                                                          icon: Icons.movie_creation_outlined,
                                                          color: Colors.pink,
                                                          title: "Reel",
                                                          subtitle: "Share a short video",
                                                          onTap: () { 
                                                            Get.back(); 
                                                            // Vertical format picker (9:16)
                                                            Get.to(() => const ReelMediaPickerScreen());
                                                          },
                                                        ),
                                                        const SizedBox(height: 16),
                                                        _buildCreateOption(
                                                          icon: Icons.live_tv_rounded,
                                                          color: Colors.redAccent,
                                                          title: "Live",
                                                          subtitle: "Go live with your followers",
                                                          onTap: () { 
                                                            Get.back();
                                                            showComingSoonDialog(
                                                              Get.context!,
                                                              title: "Live Streaming",
                                                              message: "Go live feature is coming soon!",
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(height: 16),
                                                        _buildCreateOption(
                                                          icon: Icons.camera_alt_rounded,
                                                          color: Colors.orange,
                                                          title: "Story",
                                                          subtitle: "Capture a moment",
                                                          onTap: () { 
                                                            Get.back(); 
                                                            // Use same logic as home screen add story
                                                            storyController.showPickerOptions();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  isScrollControlled: true,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.add, size: 14, color: AppColors.black),
                                                    SizedBox(width: 6),
                                                    Text("Create", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                       // Edit Profile & Share Profile Buttons Row
                                       if (!isOtherProfile) ...[
                                         Row(
                                           children: [
                                             Expanded(
                                               child: _buildActionButton("Edit Profile", () {
                                                  Get.to(() => SettingsScreen());
                                               }, isExpanded: true),
                                             ),
                                             const SizedBox(width: 10),
                                             Expanded(
                                               child: _buildActionButton("Share Profile", () {
                                                  Share.share("Check out ${user.name} (@${user.username}) on iVatan!");
                                               }, isExpanded: true),
                                             ),
                                           ],
                                         ),
                                       ],
                                       
                                       if (isOtherProfile) ...[
                                         Row(
                                           children: [
                                             Expanded(child: _buildFollowButton(user)),
                                             if (!isPrivateHidden) ...[
                                               const SizedBox(width: 8),
                                               Expanded(
                                                 child: _buildActionButton("Message", () async {
                                                   final chatId = await chatController.createSinglePrivateChat(user.id!);
                                                   if (chatId != null) {
                                                     Get.toNamed(AppRoutes.chattingScreen, arguments: chatId);
                                                   } else {
                                                     CustomSnackBar.showError(message: "Could not initiate chat");
                                                   }
                                                 }, isExpanded: true),
                                               ),
                                               const SizedBox(width: 8),
                                               Expanded(
                                                 child: _buildActionButton("Contact", () {
                                                   _showContactBottomSheet(user);
                                                 }, isExpanded: true),
                                               ),
                                             ],
                                           ],
                                         ),
                                       ],
                                       SizedBox(height: 16),
                                       Obx(() {
                                          final isFollowing = profileController.followController.isUserFollowing(user.id!).value;
                                          final bool isPrivateHidden = isOtherProfile && 
                                                                     user.accountPrivacy == "private" && 
                                                                     !isFollowing;
                                                                     
                                          if (controller.isLoading.value || isPrivateHidden) return const SizedBox.shrink();
                                          return SizedBox(
                                            height: 90,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller.highlights.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index == 0) return GestureDetector(onTap: (){}, child: _buildAddStory());
                                                final story = controller.highlights[index - 1];
                                                return GestureDetector(
                                                    onTap: () => Get.to(() => HighlightScreenStoryViewer(stories: story.stories, highlightId: story.id, initialIndex: 0)),
                                                    child: _buildStoryItem(story.title, story.cover_media_url)
                                                );
                                              },
                                            ),
                                          );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Profile Picture (Moved to ensure top z-index)
                            Positioned(
                              top: 190, // 240 - 50
                              left: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: NetworkImage(
                                      AppUrls.getFullImageUrl(user.profilePhotoPath)
                                  ),
                                  onBackgroundImageError: (_,__) {},
                                  child: (user.profilePhotoPath == null || user.profilePhotoPath!.isEmpty)
                                      ? Icon(Icons.person, color: Colors.grey.shade400, size: 60)
                                      : null,
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .scale(duration: 600.ms, curve: Curves.easeOutBack)
                                 .fadeIn()
                                    .then(delay: 500.ms)
                                 .moveY(begin: 0, end: -3, duration: 1500.ms, curve: Curves.easeInOut),
                              ),
                              ),

                          ],
                        ),
                      ),
                      
                        SliverToBoxAdapter(child: const SizedBox.shrink()),
                      
                      if (!isPrivateHidden)
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            isScrollable: false,
                            dividerColor: Colors.grey.shade200,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            indicatorWeight: 2,
                            labelPadding: EdgeInsets.symmetric(horizontal: 12),
                            tabs: [
                              Tab(child: Image.asset(AppAssets.icCategory, width: 24, height: 24)), 
                              Tab(child: Image.asset(AppAssets.icVideo, width: 24, height: 24)),
                              Tab(child: Image.asset(AppAssets.icProduct, width: 24, height: 24)),
                              Tab(child: Icon(Icons.person_add_alt_1_outlined, color: Colors.black, size: 26)), 
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: isPrivateHidden 
                    ? _buildPrivatePlaceholder()
                    : TabBarView(
                    children: [
                      MyPostScreen(username: finalUserName),
                      MyVideoScreen(username: finalUserName),
                      const ProfileShopScreen(),
                      ProfileLivePostsScreen(username: finalUserName),
                    ],
                  ),
                ),



              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic user, int index) {
      final isFollowing = profileController.followController.isUserFollowing(user.id!).value;
      final bool isPrivateHidden = isOtherProfile && 
                                 user.accountPrivacy == "private" && 
                                 !isFollowing;
                                 
      return InkWell(
          onTap: () {
               if (isPrivateHidden) return;
               Get.to(() => FollowTabs(initialTab: index, userId: user.id!))?.then((_) {
                 // Refresh profile data when coming back
                 profileController.fetchUserDetails(finalUserName);
               });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
      );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, {required bool isExpanded}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // Light grey background
            borderRadius: BorderRadius.circular(8),
             // border: Border.all(color: Colors.grey.shade300)
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      );
  }
  
  Widget _buildFollowButton(UserData user) {
       return Obx(() {
        final isFollowing = profileController.followController.isUserFollowing(user.id!, initialValue: user.is_following).value;
        return InkWell(
          onTap: () {
            if (isFollowing) {
              _showUnfollowBottomSheet(user);
            } else {
              profileController.toggleFollowForPostUser(user.id!);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isFollowing ? Colors.grey.shade100 : Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isFollowing ? "Following" : "Follow",
                style: TextStyle( color: isFollowing ? Colors.black : Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        );
       });
  }

  Widget _buildPrivatePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Icon(Icons.lock_outline, size: 50, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          const Text(
            "This Account is Private",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Follow to see their posts and photos.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showUnfollowBottomSheet(dynamic user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (user.profilePhotoPath != null && user.profilePhotoPath!.isNotEmpty)
                  ? NetworkImage(AppUrls.getFullImageUrl(user.profilePhotoPath))
                  : null,
              child: (user.profilePhotoPath == null || user.profilePhotoPath!.isEmpty)
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
                profileController.toggleFollowForPostUser(user.id!);
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

  void _showContactBottomSheet(dynamic user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Contact Options",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text("Call"),
              subtitle: Text(user.phone ?? "No phone number"),
              onTap: () async {
                if (user.phone != null) {
                  final Uri launchUri = Uri(scheme: 'tel', path: user.phone);
                  await launchUrl(launchUri);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text("Email"),
              subtitle: Text(user.email ?? "No email address"),
              onTap: () async {
                if (user.email != null) {
                  final Uri params = Uri(
                    scheme: 'mailto',
                    path: user.email,
                    query: 'subject=Inquiry from iVatan',
                  );
                  await launchUrl(params);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }


  // Widget build(BuildContext context) {
  //   return
  //     Container(
  //     child: Scaffold(
  //       backgroundColor: AppColors.neutralGray,
  //       // appBar: AppBar(
  //       //   backgroundColor: AppColors.neutralGray,
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
  //                                     style: TextStyle(color: AppColors.neutralGray),
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
  //                                       style: TextStyle(color: AppColors.neutralGray),
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
  //                                       style: TextStyle(color: AppColors.neutralGray),
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
  //                                                     AppColors.neutralGray,
  //                                                     AppColors.neutralGray,
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
  //                                                     color: AppColors.neutralGray,
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
  //                                                   color: AppColors.neutralGray,
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
  //                                                   color: AppColors.neutralGray,
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
            color: AppColors.neutralGray,
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

  Widget _buildCreateOption({
    required IconData icon,
    required Color color,
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}




