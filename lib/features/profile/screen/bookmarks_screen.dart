import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../reels_screen/model/reel_model.dart';
import '../../reels_screen/persentation/reels_view.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../controller/bookmark_controller.dart';
import 'profile_feed_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookmarkController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text("Bookmarks", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchBookmarks();
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.bookmarkedPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.bookmarkedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No bookmarks yet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 8),
                  const Text("Saved posts will appear here", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: controller.bookmarkedPosts.length,
            itemBuilder: (context, index) {
              final item = controller.bookmarkedPosts[index];
              final String thumb = (item.media.isNotEmpty)
                  ? (item.media.first.thumbnail.isNotEmpty
                      ? item.media.first.thumbnail
                      : item.media.first.url)
                  : "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg";

              return GestureDetector(
                onTap: () {
                  if (item.type == 'reel') {
                    final reelsList = controller.bookmarkedPosts.where((p) => p.type == 'reel').toList();
                    final reelIndex = reelsList.indexWhere((r) => r.id == item.id);
                    
                    if (reelIndex != -1) {
                      final mappedReels = reelsList.map((p) => ReelModel(
                        id: p.id,
                        uuid: p.uuid,
                        caption: p.caption,
                        isMine: p.is_mine,
                        isFollowing: p.is_following,
                        user: UserModel(
                          id: p.user.id,
                          name: p.user.name,
                          username: p.user.username,
                          avatar: p.user.avatar ?? "",
                          isVerified: p.user.isVerified,
                          interests: "",
                        ),
                        media: p.media.map((m) => MediaModel(
                          id: m.id,
                          type: m.type,
                          url: m.url,
                          thumbnail: m.thumbnail,
                          mimeType: "",
                        )).toList(),
                        stats: ReelStats(
                          likeCount: p.stats.likeCount ?? 0,
                          isLiked: p.stats.isLiked ?? false,
                          commentCount: p.stats.commentCount ?? 0,
                          shareCount: p.stats.shareCount ?? 0,
                          viewCount: p.stats.viewCount ?? 0,
                          isSaved: p.stats.isSaved ?? false,
                        ),
                        createdAt: p.createdAt,
                        createdHuman: p.createdHuman,
                      )).toList();

                      Get.to(() => ReelsView(
                        reels: mappedReels,
                        initialIndex: reelIndex,
                      ));
                    }
                  } else {
                    // Note: ProfileFeedScreen expects an OwnPostController which BookmarkController is not.
                    // We might need a separate feed view or a compatible one.
                    // For now, let's use a simple view or navigate assuming compatibility if possible.
                    // Since it expects OwnPostController, let's just show a simple snackbar or navigate to a generic feed.
                    Get.to(() => ProfileFeedScreen(
                      posts: controller.bookmarkedPosts,
                      initialIndex: index,
                    ));
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: (index % 2 == 0) ? 240 : 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumb,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AppAssets.imgAppLogo,
                            fit: BoxFit.cover,
                          ),
                          fit: BoxFit.cover,
                        ),
                        if (item.type == 'video' || item.type == 'reel')
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 24),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
