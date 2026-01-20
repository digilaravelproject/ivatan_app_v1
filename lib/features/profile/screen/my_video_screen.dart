import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../controller/ownpostController.dart';

class MyVideoScreen extends StatelessWidget {
  final String username;
  MyVideoScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OwnPostController controller = Get.put(OwnPostController(filterType: "videos", UserName: username ));
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.isLoading.value &&
              controller.isMoreDataAvailable.value &&
              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
            controller.fetchOwnPosts(loadMore: true);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchOwnPosts(filterType: "videos", username: username);
          },
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 2), // Tiny gap
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0), // Full width
                    child: Obx(() {
                      if (controller.isLoading.value && controller.posts.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.posts.isEmpty) {
                        return const Center(child: Text("No videos found"));
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          childAspectRatio: 0.7, // Taller for functionality feeling (Reels/TikTok style)
                        ),
                        itemCount: controller.posts.length,
                        itemBuilder: (context, index) {
                          final post = controller.posts[index];
                          // Safely get thumbnail
                          String thumb = "";
                          if(post.media.isNotEmpty) {
                             thumb = post.media.first.thumbnail.isNotEmpty 
                                ? post.media.first.thumbnail 
                                : post.media.first.url;
                          }

                          return GestureDetector(
                              onTap: () {
                                if(post.media.isNotEmpty) {
                                  Get.to(() => VideoPlayerScreen(
                                    videoUrl: post.media.first.url,
                                    videoId: post.id,
                                  ));
                                }
                              },
                              child: _buildVideoItem(thumb, post.stats.viewCount)
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(String imageUrl, int viewCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        image: imageUrl.isNotEmpty ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (_, __) {}
        ) : null,
      ),
      child: Stack(
        children: [
          if(imageUrl.isEmpty) const Center(child: Icon(Icons.videocam_off, color: Colors.grey)),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Play Icon + Views Count
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  _formatCount(viewCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
