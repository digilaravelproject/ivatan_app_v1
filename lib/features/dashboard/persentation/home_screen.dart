import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/features/dashboard/controller/create_story_controller.dart';
import 'package:i_vatan_app/features/dashboard/persentation/settings_page.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/helper/expandable_text.dart';
import '../../../core/network/app_urls.dart';
import '../../messages/persentation/dashboard.dart';
import '../../messages/persentation/message_screen.dart';
import '../../post/presentation/image_post_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../quick_access/persentation/drawerScreen.dart';
import '../../story/persentation/storyfullview.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../controller/comment_controller.dart';
import '../controller/follow_controller.dart';
import '../controller/homeController.dart';
import '../controller/navigationController.dart';
import '../model/post_model.dart';
import 'full_image_viewer.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final controller = Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final StoryController storyController = Get.put(StoryController());
   // final HomeController controller = Get.find<HomeController>();
    final FollowController followController = Get.put(FollowController());
    final user = SharedPrefManager().user;
    final imageUrl = user?.profilePhotoPath ?? "";
    final String name = user?.name ?? "Guest User";
    final token = user?.token;
    final user_id = user?.id;
    //final controller = Get.put(HomeController(), permanent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        controller.showWelcomeDialog(context);
      });
    });

    print("profilePhotoPath : "+AppUrls.imageurl+imageUrl);

    return Container(
      /*decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7AB6F0),
            Color(0xFFB3E5F5),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),*/
      child:
      Scaffold(
        backgroundColor: AppColors.black,
        key: controller.scaffoldKey, // 🔥 MOST IMPORTANT
        endDrawer: DrawerScreen(), // your drawer file
        endDrawerEnableOpenDragGesture: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        //  titleSpacing: 12,
          leadingWidth: 60,
          /*leading: Padding(
            padding: const EdgeInsets.only(left: 13), // ⭐ leading me margin
            child: GestureDetector(
              onTap: () {
                Get.to(ProfileScreen());
              },
              child: Container(
               // width: 70,
               // height: 40,
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.blue, width: 2),
                //   borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(15),
                //     topRight: Radius.circular(15),
                //     bottomLeft: Radius.circular(15),
                //     bottomRight: Radius.circular(15),
                //   ),
                // ),
                child:
                // Obx(() {
                //   final user = controller.currentUser.value;
                //   final imageUrl = user?.profilePhotoPath ?? "";
                //
                //   print("b vd iugednmv suif wf e : "+AppUrls.imageurl + imageUrl);
                //
                //   return Image.network(
                //     imageUrl.isNotEmpty
                //         ? AppUrls.imageurl + imageUrl
                //         : "https://i.pravatar.cc/150?img=10",
                //     fit: BoxFit.cover,
                //   );
                // })
                *//*ClipRRect(
                //  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl.isNotEmpty
                        ? AppUrls.imageurl+imageUrl
                        : "https://i.pravatar.cc/150?img=10",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppAssets.imgAppLogo,   // 👈 YOUR ASSET IMAGE
                        fit: BoxFit.cover,
                      );
                    },
                  ),

                ),*//*
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        imageUrl.isNotEmpty
                            ? AppUrls.imageurl + imageUrl
                            : "https://i.pravatar.cc/150?img=10",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppAssets.imgAppLogo,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),*/
          title: Text(
           // name.toString(),
          "  i-app",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12), // ⭐ actions me margin
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () {
                      Get.to(dashboard());
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.menu_open_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.openDrawer();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels > 50) {
              controller.showStories.value = true;
            }
            if (!controller.isLoading.value &&
                controller.isMoreDataAvailable.value &&
                scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
              controller.fetchPosts(loadMore: true);
            }

            return true;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchPosts();
              await controller.fetchStories();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (!controller.showStories.value) return SizedBox.shrink();
                    if (controller.isStoryLoading.value) {
                      return SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.storyData.length + 1,
                        itemBuilder: (context, index) {
                          // Add Story Button
                          if (index == 0) {
                            return GestureDetector(
                              onTap: () {
                                storyController.showPickerOptions();
                              },
                              child: _buildAddStory(imageUrl),
                            );
                          }
                          final storyIndex = index - 1;
                          final story = controller.storyData[storyIndex];

                          return GestureDetector(
                            onTap: () {
                              Get.to(() => FullScreenStoryViewer(
                                stories: story.stories,
                                initialIndex: 0,
                              ));
                            },
                            child: _buildStoryItem(
                              story.user.name,
                              story.user.avatar ?? "",
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                /// ================= POSTS =================
                Obx(() {
                  if (controller.isLoading.value && controller.posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("No Posts Available")),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = controller.posts[index];
                        final mediaUrl = post.media.isNotEmpty
                            ? post.media.first.thumbnail
                            : "";

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// ================= HEADER =================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /// Avatar
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(ProfileScreen(viewUserName: post.user.username,));
                                      // final nav = Get.find<NavigationController>();
                                      // nav.changePage(4, username: post.user.username);
                                    },
                                    child:Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.orange.shade400, Colors.pink.shade500],
                                        ),
                                      ),
                                      child:  CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage: post.user.avatar != null &&
                                            post.user.avatar!.isNotEmpty
                                            ? NetworkImage(post.user.avatar!)
                                            : const AssetImage(AppAssets.imgAppLogo)
                                        as ImageProvider,
                                      ),
                                    ),

                                  ),

                                  const SizedBox(width: 12),

                                  /// Name + Interests (ONLY THIS SHOULD EXPAND)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            Get.to(ProfileScreen(viewUserName: post.user.username,));
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                post.user.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.white
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (post.user.isVerified)
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 4),
                                                  child: Icon(
                                                    Icons.verified,
                                                    color: Colors.blue,
                                                    size: 16,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        //const SizedBox(height: 2),
                                        Text(
                                          post.user.occupation ,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                         // maxLines: 1,
                                         // overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// Follow Button (Fixed width)
                                  if (!post.is_mine) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        if (post.user.id != null) {
                                          controller.toggleFollowForPostUser(post.user.id!);
                                        }
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.white),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          post.is_following ? "Following" : "Follow",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  /// More Icon (ALWAYS RIGHT ALIGNED)
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTapDown: (details) {
                                      _showSideMenu(context, details.globalPosition,post.id);
                                    },
                                    child: const Icon(Icons.more_vert, color: AppColors.white),
                                  ),
                                ],
                              ),


                              const SizedBox(height: 10),

                              /// ================= MEDIA =================
                              if (mediaUrl.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    if (post.type == "video") {
                                      Get.to(() => VideoPlayerScreen(
                                        videoUrl: post.media.first.url,
                                        videoId: post.id,
                                      ));
                                    }
                                      else if (post.media.first.type == "reel") {
                                        //  Get.to(() => ReelPlayerScreen(url: item.media.first.url));
                                      }
                                      else if (post.media.first.type == "image") {
                                        Get.to(()=>ImagePostScreen(postId: post.id,));
                                        //  Get.to(() => ImagePreviewScreen(url: item.media.first.url));
                                      }
                                  },
                                  onDoubleTap: () {
                                    controller.likePost(post.id, index);
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          mediaUrl,
                                          height: 350,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stack) {
                                            return Image.asset(
                                              AppAssets.imgOnbording3,
                                              height: 250,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      if (post.type == "video")
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Icon(
                                            Icons.videocam_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 10),

                              /// ================= ACTIONS =================
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      controller.likePost(post.id, index);
                                    },
                                    child: Icon(
                                      post.stats.isLiked == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post.stats.isLiked == true
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(width: 4),
                                  Text("${post.stats.likeCount ?? 0}",style: TextStyle(color: AppColors.white), ),

                                  const SizedBox(width: 20),

                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => CommentsBottomSheet(
                                          postId: post.id,
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.message, color: AppColors.white),
                                  ),

                                  const SizedBox(width: 4),
                                  Text("${post.stats.commentCount ?? 0}",style: TextStyle(color: AppColors.white)),

                                  const SizedBox(width: 20),

                                  GestureDetector(
                                    onTap: () {
                                        final link = "https://ivatan.in/post/${post.id}?type=${post.media.first.type}";
                                          //  "${post.id}?type=${post.media.first.type}";
                                        Share.share("Check this post 👇\n$link");
                                    },
                                    child: Image.asset(AppAssets.imgShare,height: 24,width: 24,color: AppColors.white,)
                                  ),

                                  const SizedBox(width: 4),
                                  Text("${post.stats.shareCount ?? 0}",style: TextStyle(color: AppColors.white)),
                                ],
                              ),

                              const SizedBox(height: 10),
                              ExpandableCaption(text: post.caption ?? ""),

                              // Text(
                              //   post.caption ?? "",
                              //   style:
                              //   const TextStyle(fontSize: 14, height: 1.4,color: AppColors.white),
                              // ),
                            ],
                          ),
                        );
                      },
                      childCount: controller.posts.length,
                    ),
                  );
                }),

                /// ================= LOADER (pagination bottom) =================
                Obx(() {
                  return controller.isMoreDataAvailable.value
                      ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                      : SliverToBoxAdapter(child: SizedBox.shrink());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPostItem({
    required String name,
    required String time,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ----------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=8',
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // IMAGE ----------
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            // ACTIONS ----------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 15),
                  Icon(Icons.message),
                  SizedBox(width: 15),
                  Icon(Icons.share),
                ],
              ),
            ),

            // CAPTION ----------
            const Text(
              'It is a long established fact that a reader...',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStory(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors:
                    //story['isNew'] == true
                        //?
                    [Colors.purple, Colors.pink]
                      //  :[Colors.orange, Colors.pink],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3), // border thickness
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl.isNotEmpty
                            ? AppUrls.imageurl + imageUrl
                            : "https://i.pravatar.cc/150?img=10",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppAssets.imgAppLogo,
                            fit: BoxFit.cover,
                          );
                        },
                      ),

                    ),
                  ),
                ),
              ),

             // if (story['isNew'] == true)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Your story",
            style: const TextStyle(fontSize: 12,color: AppColors.primaryDark,fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
     /* Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              //    border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your story',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );*/
  }

  Widget _buildStoryItem(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors:
                    //story['isNew'] == true
                     //   ? [Colors.purple, Colors.pink]
                       // :
                    [Colors.orange, Colors.pink],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3), // border thickness
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 12,color: AppColors.white,fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

      /*Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );*/
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Save'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Block'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSideMenu(BuildContext context, Offset position,int postId) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
         PopupMenuItem(
          child: InkWell(
            onTap: (){
              controller.openReportBottomSheet(postId:postId);
            },
            child: ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text("Report"),
            ),
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.bookmark_border),
            title: Text("Save"),
          ),
        ),
        const PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.block_outlined),
            title: Text("Block"),
          ),
        ),
      ],
    );
  }
}


class LoopHomeScreen extends StatelessWidget {
  const LoopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Stories Section
                _buildStories(),

                // Feed
                Expanded(
                  child: ListView(
                    children: [
                      _buildPost(
                        username: 'mindcast',
                        verified: true,
                        likes: '107k',
                        time: '12h ago',
                      ),
                      _buildPost(
                        username: 'moodrealms',
                        verified: true,
                        likes: '89k',
                        time: '5h ago',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigation(context),
    );

  }

  // Header Widget
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'I - Vatan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white
              ,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.notifications,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stories Widget
  Widget _buildStories() {
    final stories = [
      {'name': 'Your Loop', 'isNew': true},
      {'name': 'mindcast', 'isNew': false},
      {'name': 'vibeteller', 'isNew': false},
      {'name': 'moodrealms', 'isNew': false},
      {'name': 'inkdrop', 'isNew': false},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Stack(
                  children: [
                    /* Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: story['isNew'] == true
                              ? [Colors.purple, Colors.pink]
                              : [Colors.orange, Colors.pink],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          // child: Padding(
                          //   padding: const EdgeInsets.all(2),
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //       color: Colors.grey,
                          //       shape: BoxShape.circle,
                          //     ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  'https://images.pexels.com/photos/39317/baby-child-happy-joy-39317.jpeg',
                                ),
                              ),
                          //   ),
                          // ),
                        ),
                      ),
                    ),*/

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: story['isNew'] == true
                              ? [Colors.purple, Colors.pink]
                              : [Colors.orange, Colors.pink],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3), // border thickness
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (story['isNew'] == true)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story['name'] as String,
                  style: const TextStyle(fontSize: 12,color: AppColors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Post Widget
  Widget _buildPost({
    required String username,
    required bool verified,
    required String likes,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade500],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.white
                          ),
                        ),
                        if (verified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const Text(
                      '🎵 Imam Malboo • Neha Nair, Kinanu Kondu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert,color: AppColors.white,),
            ],
          ),
        ),

        // Post Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300,
                      Colors.orange.shade200,
                      Colors.orange.shade100,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    Row(
                      children: [
                        _buildLikeAvatar(Colors.red.shade400),
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: _buildLikeAvatar(Colors.blue.shade400),
                        ),
                        Transform.translate(
                          offset: const Offset(-16, 0),
                          child: _buildLikeAvatar(Colors.pink.shade400),
                        ),
                      ],
                    ),
                    Text(
                      '$likes Liked',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.send,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.more_horiz,color: AppColors.white, size: 28),
            ],
          ),
        ),

        // Post Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '@vibeteller, @mooddreamlms and others liked this post!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '@mindcast soft hues, slow days, and a heart full of stillness ☕ ...more',
                style: TextStyle(fontSize: 14,color: AppColors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLikeAvatar(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  // Bottom Navigation
  Widget _buildBottomNavigation(context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.search, 'Search', false),
              const SizedBox(width: 60),
              _buildNavItem(Icons.repeat, 'Loops', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
          Positioned(
            top: -20,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}








class PostCardWidget extends StatelessWidget {
  final String username;
  final String profileImage;
  final String timeAgo;
  final String postImage;
  final String tagName;
  final String caption;
  final VoidCallback onMoreTap;

  const PostCardWidget({
    super.key,
    required this.username,
    required this.profileImage,
    required this.timeAgo,
    required this.postImage,
    required this.tagName,
    required this.caption,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ----------- HEADER ---------------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// More Icon
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onMoreTap,
                  ),
                ],
              ),
            ),

            /// ----------- IMAGE ---------------
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                postImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            /// ----------- ACTIONS + CAPTION ---------------
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.favorite_border),
                      SizedBox(width: 20),
                      Icon(Icons.message),
                      SizedBox(width: 20),
                      Icon(Icons.share_sharp),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Tag Container
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// Caption
                  Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  late final CommentController commentController;
  BuildContext? bottomSheetContext;
  final TextEditingController textController = TextEditingController();

  int? replyingToCommentId; // Track which comment we're replying to
  String? replyingToUsername; // To show in hint text

  @override
  void initState() {
    super.initState();
    commentController = Get.put(CommentController());
    commentController.fetchComments(widget.postId);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8), // Semi-transparent white
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    /// --- DRAG HANDLE ----
                    Container(
                      height: 5,
                      width: 55,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// --- COMMENT LIST ----
                    Expanded(
                      child: Obx(() {
                        if (commentController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (commentController.commentsList.isEmpty) {
                          return const Center(
                            child: Text(
                              "No comments yet!",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: commentController.commentsList.length,
                          itemBuilder: (_, index) {
                            final comment = commentController.commentsList[index];
                            return _buildMainComment(comment, index, widget.postId);
                          },
                        );
                      }),
                    ),

                    /// --- COMMENT INPUT FIELD ----
                    _buildInputField(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 *//* Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom, // This handles keyboard
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, scrollController) {
          return Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                /// --- DRAG HANDLE ----
                Container(
                  height: 5,
                  width: 55,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// --- COMMENT LIST ----
                Expanded(
                  child: Obx(() {
                    if (commentController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (commentController.commentsList.isEmpty) {
                      return const Center(
                        child: Text(
                          "No comments yet!",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: commentController.commentsList.length,
                      itemBuilder: (_, index) {
                        final comment = commentController.commentsList[index];
                        return _buildMainComment(comment, index,widget.postId);
                      },
                    );
                  }),
                ),

                /// --- COMMENT INPUT FIELD ----
                _buildInputField(),
              ],
            ),
          );
        },
      ),
    );
  }*//*

  Widget _buildMainComment(comment, int index, int postId) {
    return GestureDetector(
      onLongPressStart: (details) {
        if (comment.is_mine == true) {
          print("longpress when is mine");
          _showDeletePopupBlur(
            context,
            details.globalPosition,
            comment.id,
            index,
            postId
          );

          //  _showDeletePopup(context, details.globalPosition, comment.id, index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment.user?.avtar ?? ""),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user?.username ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(comment.body ?? ""),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    commentController.likeComment(comment.id, index);
                  },
                  child: Icon(
                    comment.hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: comment.hasLiked ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                Text("${comment.likesCount}"),
              ],
            ),

            const SizedBox(height: 8),

            // ---- REPLY TEXT ----
            GestureDetector(
              onTap: () {
                setState(() {
                  replyingToCommentId = comment.id;
                  replyingToUsername = comment.user?.username;
                });
                // Focus the text field
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                  "Reply",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ---- REPLIES (nested) ----
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 45, top: 8),
                child: Column(
                  children:
                      comment.replies.map<Widget>((reply) {
                        return _buildReply(reply);
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReply(reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(reply.user?.avtar ?? ""),
            radius: 15,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.user?.username ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(reply.body ?? ""),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Show replying indicator
          if (replyingToCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "Replying to $replyingToUsername",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        replyingToCommentId = null;
                        replyingToUsername = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText:
                        replyingToCommentId != null
                            ? "Write a reply..."
                            : "Add a comment...",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: () async {
                  final text = textController.text.trim();
                  if (text.isNotEmpty) {
                    if (replyingToCommentId != null) {
                      print("reply to comment ");
                      // Reply mode - call reply API
                      await commentController.createReplyComment(
                        commentId: replyingToCommentId!,
                        body: text,
                        postId: widget.postId,
                      );
                    } else {
                      print("craete omment ");
                      // Comment mode - call comment API
                      await commentController.createComment(
                        postId: widget.postId,
                        body: text,
                      );
                      Navigator.pop(context, commentController.commentsList.length);
                    }

                    textController.clear();
                    setState(() {
                      replyingToCommentId = null;
                      replyingToUsername = null;
                    });
                  }
                },
                child: const Icon(Icons.send, color: Colors.blue, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  *//*void _showDeletePopup(
      BuildContext context,
      Offset position,
      int commentId,
      int index,
      ) {
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 10),
              Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onTap: () async {
            //await commentController.deleteComment(commentId);

            Future.delayed(const Duration(milliseconds: 100), () {
              commentController.commentsList.removeAt(index);
            });
          },
        ),
      ],
    );
  }
*//*

  void _showDeletePopupBlur(
    BuildContext context,
    Offset position,
    int commentId,
    int index, int postId
  ) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry blurEntry;
    late OverlayEntry popupEntry;

    blurEntry = OverlayEntry(
      builder:
          (_) => GestureDetector(
            onTap: () {
              blurEntry.remove();
              popupEntry.remove();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
    );

    popupEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 40,
          top: position.dy - 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () async {
                  blurEntry.remove();
                  popupEntry.remove();
                  await commentController.deleteComments(postId,commentId);
                  commentController.commentsList.removeAt(index);
                  Navigator.pop(bottomSheetContext!,);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(blurEntry);
    overlayState.insert(popupEntry);
  }
}*/








class CommentsBottomSheet extends StatefulWidget {
  final int postId;
  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  late final CommentController commentController;
  BuildContext? bottomSheetContext;
  final TextEditingController textController = TextEditingController();

  int? replyingToCommentId;
  String? replyingToUsername;

  @override
  void initState() {
    super.initState();
    commentController = Get.put(CommentController());
    commentController.fetchComments(widget.postId);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.85),
                      Colors.white.withOpacity(0.55),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    /// --- HEADER ----
                    _buildHeader(),

                    Divider(height: 1, color: Colors.grey.shade100),

                    /// --- COMMENT LIST ----
                    Expanded(
                      child: Obx(() {
                        if (commentController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (commentController.commentsList.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: commentController.commentsList.length,
                          itemBuilder: (_, index) {
                            final comment = commentController.commentsList[index];
                            return _buildMainComment(comment, index, widget.postId);
                          },
                        );
                      }),
                    ),

                    /// --- COMMENT INPUT FIELD ----
                    _buildInputField(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          // Drag handle
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Obx(() => Text(
                      "${commentController.commentsList.length} ${commentController.commentsList.length == 1 ? 'comment' : 'comments'}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No comments yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your thoughts!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainComment(comment, int index, int postId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          GestureDetector(
            onLongPressStart: (details) {
              if (comment.is_mine == true) {
                _showDeletePopupBlur(
                  context,
                  details.globalPosition,
                  comment.id,
                  index,
                  postId,
                  isReply: false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: (comment.user?.avtar != null &&
                            comment.user?.avtar != "")
                            ? NetworkImage(comment.user!.avtar!)
                            : null,
                        child: (comment.user?.avtar == null ||
                            comment.user?.avtar == "")
                            ? Icon(
                          Icons.person,
                          color: Colors.grey.shade700,
                          size: 24,
                        )
                            : null,
                      ),
                      if (comment.is_mine == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Comment content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username and time
                        Row(
                          children: [
                            Text(
                              comment.user?.username ?? "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Comment text
                        Text(
                          comment.body ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action buttons
                        Row(
                          children: [
                            _buildActionButton(
                              icon: comment.hasLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: "${comment.likesCount}",
                              color: comment.hasLiked ? Colors.red : Colors.grey.shade700,
                              onTap: () {
                                commentController.likeComment(comment.id, index);
                              },
                            ),
                            const SizedBox(width: 20),
                            _buildActionButton(
                              icon: Icons.reply_rounded,
                              label: "Reply",
                              color: Colors.grey.shade700,
                              onTap: () {
                                setState(() {
                                  replyingToCommentId = comment.id;
                                  replyingToUsername = comment.user?.username;
                                });
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                            ),
                            if (comment.replies.isNotEmpty) ...[
                              const SizedBox(width: 20),
                              Text(
                                "${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Replies with indentation (no border line)
          if (comment.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 48),
              child: Column(
                children: comment.replies.asMap().entries.map<Widget>((entry) {
                  int replyIndex = entry.key;
                  var reply = entry.value;
                  return _buildReply(reply, index, replyIndex, widget.postId);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReply(reply, int commentIndex, int replyIndex, int postId) {
    return GestureDetector(
      onLongPressStart: (details) {
        if (reply.is_mine == true) {
          _showDeletePopupBlur(
            context,
            details.globalPosition,
            reply.id,
            commentIndex,
            postId,
            isReply: true,
            replyIndex: replyIndex,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: (reply.user?.avtar != null &&
                  reply.user?.avtar != "")
                  ? NetworkImage(reply.user!.avtar!)
                  : null,
              child: (reply.user?.avtar == null ||
                  reply.user?.avtar == "")
                  ? Icon(
                Icons.person,
                color: Colors.grey.shade700,
                size: 20,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.user?.username ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.body ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Replying indicator
          if (replyingToCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Replying to @$replyingToUsername",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        replyingToCommentId = null;
                        replyingToUsername = null;
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: replyingToCommentId != null
                          ? "Write a reply..."
                          : "Share your thoughts...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  final text = textController.text.trim();
                  if (text.isNotEmpty) {
                    if (replyingToCommentId != null) {
                      await commentController.createReplyComment(
                        commentId: replyingToCommentId!,
                        body: text,
                        postId: widget.postId,
                      );
                    } else {
                      await commentController.createComment(
                        postId: widget.postId,
                        body: text,
                      );
                      Navigator.pop(context, commentController.commentsList.length);
                    }

                    textController.clear();
                    setState(() {
                      replyingToCommentId = null;
                      replyingToUsername = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade700],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeletePopupBlur(
      BuildContext context,
      Offset position,
      int commentId,
      int commentIndex,
      int postId, {
        required bool isReply,
        int? replyIndex,
      }) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry blurEntry;
    late OverlayEntry popupEntry;

    blurEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        onTap: () {
          blurEntry.remove();
          popupEntry.remove();
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
      ),
    );

    popupEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 80,
          top: position.dy - 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.red.withOpacity(0.4),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () async {
                  blurEntry.remove();
                  popupEntry.remove();

                  if (isReply && replyIndex != null) {
                    // Delete reply
                    Navigator.pop(context);
                    await commentController.deleteComments(postId, commentId);
                    commentController.commentsList[commentIndex].replies.removeAt(replyIndex);

                  } else {
                    // Delete main comment
                    await commentController.deleteComments(postId, commentId);
                    commentController.commentsList.removeAt(commentIndex);
                  }

                  if (!isReply) {
                    Navigator.pop(bottomSheetContext!);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(blurEntry);
    overlayState.insert(popupEntry);
  }
}





class PostMediaWidget extends StatefulWidget {
  final PostItem post;
  final int index;
  final HomeController controller;

  const PostMediaWidget({
    super.key,
    required this.post,
    required this.index,
    required this.controller,
  });

  @override
  State<PostMediaWidget> createState() => _PostMediaWidgetState();
}

class _PostMediaWidgetState extends State<PostMediaWidget>
    with SingleTickerProviderStateMixin {
  bool showHeart = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation =
        Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack,
        ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _animationController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void handleDoubleTap() {
    widget.controller.likePost(widget.post.id, widget.index);

    setState(() {
      showHeart = true;
    });

    _animationController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        showHeart = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.post.media.isNotEmpty ? widget.post.media.first.url : "";

    return GestureDetector(
      onDoubleTap: handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              mediaUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Image.asset(
                  AppAssets.imgOnbording3,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Video icon
          if (widget.post.type == "video")
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),

          // Heart Animation
          if (showHeart)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.9),
                size: 100,
              ),
            ),
        ],
      ),
    );
  }
}





