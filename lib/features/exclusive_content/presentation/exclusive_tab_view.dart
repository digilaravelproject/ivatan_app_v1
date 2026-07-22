import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/data/model/res/user_model.dart';
import '../../reels_screen/model/reel_model.dart' as rm;
import '../controller/exclusive_controller.dart';
import 'dart:ui';
import '../../profile/controller/ownpostController.dart';
import '../../profile/screen/profile_feed_screen.dart';
import '../../reels_screen/persentation/reels_view.dart';
import '../../dashboard/model/post_model.dart';

class ExclusiveTabView extends StatefulWidget {
  final String username;
  final bool isOwnProfile;

  const ExclusiveTabView({
    Key? key,
    required this.username,
    required this.isOwnProfile,
  }) : super(key: key);

  @override
  State<ExclusiveTabView> createState() => _ExclusiveTabViewState();
}

class _ExclusiveTabViewState extends State<ExclusiveTabView> {
  late final OwnPostController postController;
  final ExclusiveController exclusiveController = Get.find<ExclusiveController>();

  @override
  void initState() {
    super.initState();
    postController = Get.put(
      OwnPostController(filterType: "exclusive", UserName: widget.username),
      tag: "${widget.username}_exclusive_posts",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (postController.isLoading.value && postController.posts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      
      if (postController.posts.isEmpty) {
        return const Center(child: Text("No exclusive posts found."));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(2),
        itemCount: postController.posts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final post = postController.posts[index];
          
          // Determine if purchased/locked based on API response logic
          bool isPurchased = post.isPurchased ?? false;
          bool hasAccess = post.hasAccess ?? false;
          bool isLocked = !widget.isOwnProfile && !isPurchased && !hasAccess;
          String price = "₹${post.price ?? '0'}";
          
          String imageUrl = "";
          if (post.media != null && post.media!.isNotEmpty) {
            imageUrl = post.media!.first.url ?? "";
          }

          void openPost() {
            if (post.type == 'reel') {
              // Filter only reels from postController
              final reelsList = postController.posts.where((p) => p.type == 'reel').toList();
              final reelIndex = reelsList.indexWhere((r) => r.id == post.id);
              
              if (reelIndex != -1) {
                // Map to ReelModel
                final mappedReels = reelsList.map((p) => rm.ReelModel(
                  id: p.id,
                  uuid: p.uuid,
                  caption: p.caption,
                  isMine: p.is_mine,
                  isFollowing: p.is_following,
                  user: rm.UserModel(
                    id: p.user.id,
                    name: p.user.name,
                    username: p.user.username,
                    avatar: p.user.avatar ?? "",
                    isVerified: p.user.isVerified,
                    interests: "",
                  ),
                  media: p.media.map((m) => rm.MediaModel(
                    id: m.id,
                    type: m.type,
                    url: m.url,
                    thumbnail: m.thumbnail,
                    mimeType: "",
                  )).toList(),
                  stats: rm.ReelStats(
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
                posts: postController.posts,
                initialIndex: index,
                controller: postController, // Pass the OwnPostController
              ));
            }
          }

          return GestureDetector(
            onTap: () {
              if (isLocked) {
                _showPurchaseDialog(context, exclusiveController, price, post.id ?? 0, () {
                  post.isPurchased = true;
                  post.hasAccess = true;
                  postController.posts.refresh();
                  openPost();
                });
              } else {
                openPost();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Container(
                  color: Colors.grey.shade300,
                  child: imageUrl.isNotEmpty 
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.image, color: Colors.grey, size: 40),
                ),
                
                // Blur & Lock Overlay if locked
                if (isLocked) ...[
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        color: Colors.black26, // Light dark overlay so image is still visible
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 1),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black12, // Very subtle dark tint
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text("Unlock for $price", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              // Top right lock icon indicator
              if (isLocked)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.lock, color: Colors.grey, size: 18),
                )
              else if (!widget.isOwnProfile)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.lock_open, color: Colors.grey, size: 18),
                ),
            ],
            ),
          );
        },
      );
    });
  }

  void _showPurchaseDialog(BuildContext context, ExclusiveController controller, String price, int postId, VoidCallback onSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Unlock Content"),
          content: Text("This is exclusive content. Would you like to unlock it for $price?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Call initiate purchase
                bool success = await controller.initiatePurchase(postId);
                if (success) {
                  onSuccess();
                }
              },
              child: const Text("Unlock"),
            ),
          ],
        );
      },
    );
  }
}
