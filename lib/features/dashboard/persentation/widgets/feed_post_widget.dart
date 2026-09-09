import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/helper/date_helper.dart';
import '../../../../core/helper/expandable_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/screen/profile_screen.dart';
import '../../controller/homeController.dart';
import '../../../reels_screen/persentation/reels_view.dart';
import '../../../reels_screen/model/reel_model.dart' as rm;
import '../../model/post_model.dart';
import '../home_screen.dart'; // For CommentsBottomSheet and _showSideMenu
import 'feed_media_widget.dart';

// Since _showSideMenu is private in HomeScreen, we might need to duplicate it or better yet, 
// move it to a shared helper or make it part of this widget. 
// For now, I'll copy the _showSideMenu logic here as well to make this standalone.

class FeedPostWidget extends StatelessWidget {
  final PostItem post;
  final int index;
  final dynamic controller; 
  // We use dynamic to support HomeController and OwnPostController.
  // Both must implement likePost(int, int) and followController access.

  const FeedPostWidget({
    Key? key, 
    required this.post, 
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== POST HEADER ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => Get.to(() => ProfileScreen(viewUserName: post.user.username)),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryBackground,
                        border: Border.all(color: AppColors.premiumGold.withOpacity(0.3), width: 1),
                    ),
                    child: ClipOval(
                      child: post.user.avatar != null && post.user.avatar!.isNotEmpty && !post.user.avatar!.contains("ui-avatars.com")
                          ? Image.network(
                              post.user.avatar!, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: AppColors.premiumGold, size: 24),
                            )
                          : Icon(Icons.person, color: AppColors.premiumGold, size: 24),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Name, Occupation & Song
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => Get.to(() => ProfileScreen(viewUserName: post.user.username)),
                              child: Text(
                                post.user.username.isNotEmpty ? post.user.username : post.user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (post.user.isVerified) ...[
                            const SizedBox(width: 4),
                            Image.asset(AppAssets.imgverified,height: 16,width: 16, color: AppColors.successSoftGold),
                          ],
                          
                          // Date / Time
                          Text(
                            " • ${DateHelper.formatPostDate(post.createdAt)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      
                      // Song Info / Location / Occupation
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          children: [
                            if (post.type == 'video') ...[
                               Icon(Icons.music_note, size: 12, color: AppColors.premiumGold),
                               const SizedBox(width: 4),
                            ],
                            
                            Flexible(
                              child: Text(
                                post.type == 'video' ? "Original Audio" : post.user.occupation,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.premiumGold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Follow Button (Only for others)
                if (!post.is_mine) ...[
                  const SizedBox(width: 8),
                  Obx(() {
                    final isFollowing = controller.followController.isUserFollowing(post.user.id, initialValue: post.is_following).value;
                    final bool following = isFollowing;

                    return GestureDetector(
                      onTap: () {
                        if (post.user.id != null) {
                          controller.toggleFollowForPostUser(post.user.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: following ? AppColors.secondaryBackground : AppColors.transparent,
                          border: Border.all(
                              color: following ? AppColors.border : AppColors.premiumGold,
                              width: 1
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          following ? "Following" : "Follow",
                          style: TextStyle(
                            color: following ? AppColors.primaryText : AppColors.premiumGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                // More Menu
                IconButton(
                   icon: const Icon(Icons.more_horiz, color: AppColors.primaryText),
                   onPressed: () => _showSideMenu(context, post.id, post.user.username, post.user.id),
                   padding: EdgeInsets.zero,
                   constraints: const BoxConstraints(),
                   splashRadius: 20,
                ),
              ],
            ),
          ),

          // ========== POST MEDIA (CAROUSEL / VIDEO) ==========
          if (post.media.isNotEmpty)
            FeedMediaWidget(
              media: post.media,
              type: post.type,
              isLiked: post.stats.isLiked ?? false,
              onDoubleTap: () => controller.likePost(post.id, index),
              onVideoTap: () {
                // Navigate to ReelsView
                // 1. Get all posts from controller
                List<PostItem> allPosts = [];
                try {
                  allPosts = controller.posts; // Assuming controller has 'posts' list
                } catch (e) {
                   // Fallback if controller doesn't support it
                   print("Error accessing controller.posts: $e");
                   return;
                }

                // 2. Filter only videos/reels and remove locked posts
                final videoPosts = allPosts.where((p) {
                   bool hasVideo = p.type == 'reel' || 
                                   p.type == 'video' || 
                                   (p.media.isNotEmpty && p.media.first.type == 'video');
                   
                   bool isPurchased = p.isPurchased ?? false;
                   bool hasAccess = p.hasAccess ?? false;
                   bool isLocked = !p.is_mine && !isPurchased && !hasAccess && (p.price != null || p.isExclusive == true);

                   return hasVideo && !isLocked;
                }).toList();

                // 3. Find index of current post in video list
                final reelIndex = videoPosts.indexWhere((p) => p.id == post.id);

                if (reelIndex != -1) {
                  // 4. Map to ReelModel
                  List<rm.ReelModel> reelsList = videoPosts.map((item) {
                     return rm.ReelModel(
                      id: item.id,
                      uuid: item.uuid, // Pass uuid if available
                      caption: item.caption ?? "",
                      isMine: item.is_mine,
                      isFollowing: item.is_following,
                      user: rm.UserModel(
                         id: item.user.id,
                         name: item.user.name,
                         username: item.user.username,
                         avatar: item.user.avatar,
                         isVerified: item.user.isVerified,
                         interests: item.user.interests // Add interests if required
                      ),
                      media: item.media.map((m) => rm.MediaModel(
                          id: m.id,
                          type: m.type,
                          url: m.url,
                          thumbnail: m.thumbnail,
                          mimeType: m.mimeType
                      )).toList(),
                       // Helper or default stats
                       stats: rm.ReelStats(
                         likeCount: item.stats.likeCount,
                         commentCount: item.stats.commentCount,
                         shareCount: item.stats.shareCount,
                         viewCount: item.stats.viewCount,
                         isLiked: item.stats.isLiked,
                         isSaved: item.stats.isSaved,
                       ),
                       createdAt: item.createdAt,
                       createdHuman: item.createdHuman,
                    );
                  }).toList();
                  
                  Get.to(() => ReelsView(
                    reels: reelsList,
                    initialIndex: reelIndex,
                  ));
                }
              },
            ),

          // ========== POST ACTIONS ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Like
                    GestureDetector(
                      onTap: () => controller.likePost(post.id, index),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              post.stats.isLiked == true ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(post.stats.isLiked),
                              color: post.stats.isLiked == true ? Colors.red : AppColors.premiumGold,
                              size: 26,
                            ),
                          ),
                          if ((post.stats.likeCount ?? 0) > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              "${post.stats.likeCount}",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.premiumGold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 20),

                    // Comment
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.transparent,
                          builder: (_) => CommentsBottomSheet(postId: post.id),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, color: AppColors.premiumGold, size: 24),
                          if ((post.stats.commentCount ?? 0) > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              "${post.stats.commentCount}",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.premiumGold),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Share
                    GestureDetector(
                      onTap: () {
                        final link = "https://ivatan.in/post/${post.id}?type=${post.media.first.type}";
                        Share.share("Check this post 👇\n$link");
                      },
                      child: Icon(Icons.share, color: AppColors.premiumGold, size: 24),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () => controller.toggleBookmark(post.id),
                      child: Icon(
                        post.stats.isSaved ? Icons.bookmark : Icons.bookmark_border, 
                        color: AppColors.premiumGold, 
                        size: 26
                      ),
                    ),
                  ],
                ),

                // Caption with Username + Rich Text
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                   const SizedBox(height: 6),
                   ExpandableCaption(
                      text: post.caption!,
                      username: post.user.username.isNotEmpty ? post.user.username : post.user.name,
                      onUsernameTap: () => Get.to(() => ProfileScreen(viewUserName: post.user.username)),
                   ),
                ]
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 0.5, color: AppColors.premiumGold),
        ],
      ),
    );
  }

  void _showSideMenu(BuildContext context, int postId, String username, int userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.premiumGold),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.premiumGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // 1. Report
            ListTile(
              leading: const Icon(Icons.report_gmailerrorred_outlined, color: Colors.redAccent),
              title: const Text("Report", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                controller.openReportBottomSheet(postId: postId);
              },
            ),
             Divider(height: 1, thickness: 0.5, color: AppColors.premiumGold, indent: 16, endIndent: 16),


            // 2. About this profile
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppColors.white),
              title: const Text("About this profile", style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                if (username.isNotEmpty) {
                  Get.to(() => ProfileScreen(viewUserName: username));
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.block, color: Colors.redAccent),
              title: const Text("Block", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                controller.blockUser(userId);
              },
            ),
            Divider(height: 1, thickness: 0.5, color: AppColors.premiumGold, indent: 16, endIndent: 16),
            
            // 4. Interested
            ListTile(
              leading: const Icon(Icons.star_border_rounded, color: AppColors.white),
              title: const Text("Interested", style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                controller.markInterested(postId);
              },
            ),
            Divider(height: 1, thickness: 0.5, color: AppColors.premiumGold, indent: 16, endIndent: 16),

            // 5. Not Interested
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined, color: AppColors.white),
              title: const Text("Not interested", style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                controller.markNotInterested(postId);
              },
            ),
            const SizedBox(height: 20),
          ],
          ),
        ),
      ),
    );
  }
}

