import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../../reels_screen/persentation/reels_view.dart';
import '../../reels_screen/model/reel_model.dart';
import '../controller/ownpostController.dart';
import 'profile_feed_screen.dart';

class MyPostScreen extends StatelessWidget {
  String username;
  MyPostScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // using unique tag to avoid conflict if both screens use same controller logic, 
    // but here we might share the controller. 
    // Actually, 'posts' filter type is same.
    final controller = Get.put(
      OwnPostController(filterType: "posts", UserName: username),
      tag: username.toString(),
      permanent: true,
    );

    return Container(
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.isLoading.value &&
              controller.isMoreDataAvailable.value &&
              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
            controller.fetchOwnPosts(loadMore: true);
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchOwnPosts(filterType: "posts", username: username);
          },
          child: Obx(() {
            if (controller.isLoading.value && controller.posts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.posts.isEmpty) {
              return const Center(child: Text("No posts found"));
            }

            return MasonryGridView.count(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: controller.posts.length,
              itemBuilder: (context, index) {
                final item = controller.posts[index];

                final String thumb = (item.media.isNotEmpty)
                    ? (item.media.first.thumbnail.isNotEmpty
                    ? item.media.first.thumbnail
                    : item.media.first.url)
                    : "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg";

                return GestureDetector(
                  onTap: () {
                    if (item.type == 'reel') {
                       // Filter only reels
                       final reelsList = controller.posts.where((p) => p.type == 'reel').toList();
                       // Find index in the new list
                       final reelIndex = reelsList.indexWhere((r) => r.id == item.id);
                       
                       if (reelIndex != -1) {
                         // Map to ReelModel
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
                             interests: "", // Default empty
                           ),
                           media: p.media.map((m) => MediaModel(
                             id: m.id,
                             type: m.type,
                             url: m.url,
                             thumbnail: m.thumbnail,
                             mimeType: "", // Default empty if not available
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
                      Get.to(() => ProfileFeedScreen(
                        posts: controller.posts,
                        initialIndex: index,
                        controller: controller, // Pass the OwnPostController
                      ));
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: (index % 2 == 0) ? 220 : 150,
                      color: Colors.grey.shade300,
                      child: FadeInImage(
                        image: NetworkImage(thumb),
                        placeholder: const AssetImage(AppAssets.imgOnbording1),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppAssets.imgAppLogo,
                            fit: BoxFit.cover,
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
