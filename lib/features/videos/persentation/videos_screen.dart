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
import '../../dashboard/persentation/comming_soon.dart'; // For CustomEmptyState
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
    return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Discover',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trending videos for you',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _showFilterBottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.grey.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                                controller.filterSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search videos...',
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
                  ],
                ),
              ),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchVideo();
                  },
                  child: Obx(() {
                    if (controller.isLoading.value && controller.posts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.posts.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: CustomEmptyState(
                                title: "No Videos Yet",
                                subTitle: "Check back later for amazing content!",
                                icon: Icons.video_library_rounded,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return GridView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: controller.filteredList.length + 1,
                      itemBuilder: (context, index) {
                        if (index < controller.filteredList.length) {
                          final video = controller.filteredList[index];
                          return _buildGridVideoCard(
                            video.media.first.thumbnail,
                            video.caption,
                            video.user.name,
                            video.user.username,
                            video.media.first.url,
                            video.id,
                            video.user.avatar,
                            video.stats.viewCount.toString(),
                          );
                        } else {
                          return controller.isMoreLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink();
                        }
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFilterOption(
              context,
              'Most Viewed',
              Icons.visibility_rounded,
              () {
                controller.sortByViews();
                Navigator.pop(context);
              },
              'views',
            ),
            _buildFilterOption(
              context,
              'Most Recent',
              Icons.access_time_rounded,
              () {
                controller.sortByRecent();
                Navigator.pop(context);
              },
              'recent',
            ),
            _buildFilterOption(
              context,
              'Most Liked',
              Icons.favorite_rounded,
              () {
                controller.sortByLikes();
                Navigator.pop(context);
              },
              'likes',
            ),
            _buildFilterOption(
              context,
              'Reset Filter',
              Icons.refresh_rounded,
              () {
                controller.resetSort();
                Navigator.pop(context);
              },
              'none',
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    String filterKey,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == filterKey;
      
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isSelected ? Colors.white : Colors.grey.shade700, 
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: Colors.grey.shade400, 
                  size: 16,
                ),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildGridVideoCard(
      String imageUrl,
      String title,
      String name,
      String username,
      String videoUrl,
      int videoid,
      String profileImage,
      String views,
      ) {
    return InkWell(
      onTap: () {
        Get.to(() => VideoPlayerScreen(videoUrl: videoUrl, videoId: videoid,), 
          fullscreenDialog: false, preventDuplicates: false);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.network(
                      imageUrl ?? "",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.video_library_rounded,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                  // Duration badge (bottom-left)
                  // Removed hardcoded duration badge
                  // Views badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(profileImage),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          name ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        Get.to(() => VideoPlayerScreen(videoUrl: videoUrl, videoId: videoid,), fullscreenDialog: false,preventDuplicates: false);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
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
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl ?? "",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.video_library_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // Play Icon Overlay (Center)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profileImage),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 10),

                    // Text Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
