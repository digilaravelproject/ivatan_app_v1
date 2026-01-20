import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/db/shared_pref_manager.dart';
import 'package:i_vatan_app/features/videos/persentation/play_video_screen.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_serchbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/controller/navigationController.dart';
import '../controller/video_controller.dart';

/*class VideosScreen extends StatelessWidget {
  VideosScreen({super.key});
  final VideoController controller = Get.put(VideoController(videoId: 0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {

            if (!controller.isLoading.value &&
                controller.isMoreDataAvailable.value &&
                scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
              controller.fetchVideo(loadMore: true);
            }

            return true;
          },
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight * 0.65),
              CustomSearchBar(),
              Expanded(
                child: Obx((){
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.posts.isEmpty) {
                    return const Center(child: Text("No posts found"));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: controller.posts.length, // Your item count
                    itemBuilder: (context, index) {
                      final video = controller.posts[index];
                      return _buildVideoCard(
                        video.media.first.thumbnail,
                        video.caption,
                        video.user.name,
                        video.user.username,
                          video.media.first.url,
                          video.id ,
                          'Creater, Photographer',
                        video.user.avatar,
                        video.stats.viewCount.toString()

                        // 'https://thumbs.dreamstime.com/b/person-walking-golden-beach-sunset-background-created-generative-ai-276103059.jpg', // Background image
                        // 'How to find love', // Title
                        // 'Ashita Patil', // Name
                        // '@ashitap', // Username
                        // 'Creater, Photographer', // Role
                        // 'https://i.pravatar.cc/150?img=1', // Profile image
                        // '125,678', // Views
                      );
                    },
                  );
                })

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    String imageUrl,
    String title,
    String name,
    String username,
    String videoUrl,
    int videoid,
    String role,
    String profileImage,
    String views,
  ) {
    return InkWell(
      onTap: (){
        // final navigationController = Get.find<NavigationController>();
        // navigationController.changePage(5);
        Get.to(() => VideoPlayerScreen(videoUrl: videoUrl, videoId: videoid,), fullscreenDialog: true);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl ?? "",   // <-- null protection
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              AppAssets.imgOnbording2,  // <-- your dummy image path
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          },
        ),
      ),


            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Views Counter (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                // decoration: BoxDecoration(
                //   color: Colors.black.withOpacity(0.5),
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      views,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bookmark Icon (Top Right)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Icon(
                  Icons.subscriptions,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),

            // Bottom Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    SizedBox(width: 12),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            '$username. $role',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Play Button
                    Container(
                     // padding: EdgeInsets.all(12),
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   border: Border.all(color: Colors.white, width: 2),
                      // ),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/



class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}
class _VideosScreenState extends State<VideosScreen> {
  final VideoController controller = Get.put(VideoController(videoId: 0));
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200 &&
          controller.isMoreDataAvailable.value &&
          !controller.isMoreLoading.value) {
        controller.fetchVideo(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: kToolbarHeight * 0.65),
            CustomSearchBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.posts.isEmpty) {
                  return const Center(child: Text("No posts found"));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchVideo();
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: controller.filteredList.length + 1, // extra loader
                    itemBuilder: (context, index) {
                      if (index < controller.filteredList.length) {
                        final video = controller.filteredList[index];
                        return _buildVideoCard(
                          video.media.first.thumbnail,
                          video.caption,
                          video.user.name,
                          video.user.username,
                          video.media.first.url,
                          video.id,
                          'Creater, Photographer',
                          video.user.avatar,
                          video.stats.viewCount.toString(),
                        );
                      } else {
                        return controller.isMoreLoading.value
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(child: CircularProgressIndicator()),
                        )
                            : const SizedBox.shrink();
                      }
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
  Widget _buildVideoCard(
      String imageUrl,
      String title,
      String name,
      String username,
      String videoUrl,
      int videoid,
      String role,
      String profileImage,
      String views,
      ) {
    return InkWell(
      onTap: (){
        // final navigationController = Get.find<NavigationController>();
        // navigationController.changePage(5);
        Get.to(() => VideoPlayerScreen(videoUrl: videoUrl, videoId: videoid,), fullscreenDialog: false,preventDuplicates: false);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            /*ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),*/
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl ?? "",   // <-- null protection
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    AppAssets.imgOnbording2,  // <-- your dummy image path
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                // decoration: BoxDecoration(
                //   color: Colors.black.withOpacity(0.5),
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      views,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bookmark Icon (Top Right)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Icon(
                  Icons.subscriptions,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),

            // Bottom Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    SizedBox(width: 12),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            '$username. $role',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Play Button
                    Container(
                      // padding: EdgeInsets.all(12),
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle,
                      //   border: Border.all(color: Colors.white, width: 2),
                      // ),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



class CustomSearchBar extends StatelessWidget {
  CustomSearchBar({Key? key}) : super(key: key);

  final VideoController controller = Get.find<VideoController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.neutralGray,
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
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        print("onchange value = "+value);
                        controller.filterSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search videos, creators...',
                        hintStyle: TextStyle(
                          color: AppColors.lightTextSecondary,
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
                  Icon(
                    Icons.search,
                    color: AppColors.lightTextSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // const SizedBox(width: 10),
          //
          // CircleAvatar(
          //   backgroundImage: NetworkImage(SharedPrefManager().user!.profilePhotoPath.toString()),
          // ),
        ],
      ),
    );
  }
}
