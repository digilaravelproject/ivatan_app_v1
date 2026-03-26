import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../../reels_screen/model/reel_model.dart' as rm;
import '../../reels_screen/persentation/reels_view.dart';
import '../controller/ownpostController.dart';
import '../../dashboard/model/post_model.dart';

class MyVideoScreen extends StatelessWidget {
  final String username;
  MyVideoScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OwnPostController controller = Get.put(OwnPostController(filterType: "videos", UserName: username ));
    return Container(
      color: AppColors.white,
      child: NotificationListener<ScrollNotification>(
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
          child: Column(
            children: [
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
                      padding: EdgeInsets.zero,
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
                              if (post.media.isNotEmpty) {
                                if (post.type == "reel") {
                                  // Convert current list of posts to ReelModels for swiping
                                  final List<rm.ReelModel> reelList = controller.posts
                                      .where((p) => p.type == "reel" && p.media.isNotEmpty)
                                      .map((p) => _convertToReelModel(p))
                                      .toList();

                                  // Find the index of the clicked reel in the filtered list
                                  final int initialIndex = reelList.indexWhere((r) => r.id == post.id);

                                  if (reelList.isNotEmpty) {
                                    Get.to(() => ReelsView(
                                      reels: reelList,
                                      initialIndex: initialIndex >= 0 ? initialIndex : 0,
                                    ));
                                  }
                                } else {
                                  Get.to(() => VideoPlayerScreen(
                                    videoUrl: post.media.first.url,
                                    videoId: post.id,
                                  ));
                                }
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
  
  rm.ReelModel _convertToReelModel(PostItem post) {
    return rm.ReelModel(
      id: post.id,
      uuid: post.uuid,
      caption: post.caption,
      isMine: post.is_mine,
      isFollowing: post.is_following,
      user: rm.UserModel(
        id: post.user.id,
        name: post.user.name,
        username: post.user.username,
        avatar: post.user.avatar,
        isVerified: post.user.isVerified,
        interests: post.user.interests,
      ),
      media: post.media.map((m) => rm.MediaModel(
        id: m.id,
        type: m.type,
        url: m.url,
        thumbnail: m.thumbnail,
        mimeType: m.mimeType,
      )).toList(),
      stats: rm.ReelStats(
        likeCount: post.stats.likeCount,
        commentCount: post.stats.commentCount,
        shareCount: post.stats.shareCount,
        viewCount: post.stats.viewCount,
        isLiked: post.stats.isLiked,
        isSaved: post.stats.isSaved,
      ),
      createdAt: post.createdAt,
      createdHuman: post.createdHuman,
      likeStatus: post.stats.isLiked,
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
