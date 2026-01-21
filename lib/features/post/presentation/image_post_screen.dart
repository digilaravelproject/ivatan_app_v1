import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/persentation/home_screen.dart';
import '../controller/image_post_controller.dart';
import '../../../core/network/app_urls.dart';

// Controller
class JobPostController extends GetxController {
  var isLiked = false.obs;
  var likeCount = 42.obs;
  var commentCount = 0.obs;
  var shareCount = 1.obs;

  void toggleLike() {
    isLiked.value = !isLiked.value;
    if (isLiked.value) {
      likeCount.value++;
    } else {
      likeCount.value--;
    }
  }

  void addComment() {
    commentCount.value++;
  }

  void share() {
    shareCount.value++;
  }
}

// Main Screen
/*class JobPostScreen extends StatelessWidget {
  const JobPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.put(JobPostController());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
        ),
        body:  SafeArea(
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildImageSection(controller),
                            _buildPostInfo(),
                          ],
                        ),
                      ),
                      _buildSideActions(controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }



  Widget _buildImageSection(JobPostController controller) {
    return Container(
      height: 500,
    //  color: Colors.black,
      child: InteractiveViewer(
        // minScale: 0.5,
        // maxScale: 4.0,
        child: Center(
          child: Image.asset(
            AppAssets.imgAppLogo, // Replace with your image asset
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }



  Widget _buildPostInfo() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade700,
            child: const Text(
              'GS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Post Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Gopal Singh',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '• 1st',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  '🎓 Training Head | DigiCoders Technologies Pvt Ltd...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text(
                      '📢 We Are Hiring – Flutter Developer...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'more',
                      style: TextStyle(
                        color: Color(0xFF3b82f6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideActions(JobPostController controller) {
    return Positioned(
      right: 12,
      bottom: 200,
      child: Column(
        children: [
          // Like
          Obx(
                () => _buildActionButtonWithCount(
              icon: controller.isLiked.value
                  ? Icons.favorite
                  : Icons.favorite_border,
              count: controller.likeCount.value,
              onPressed: controller.toggleLike,
              color: controller.isLiked.value ? Colors.red : Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Comment
          Obx(
                () => _buildActionButtonWithCount(
              icon: Icons.chat_bubble_outline,
              count: controller.commentCount.value,
              onPressed: controller.addComment,
            ),
          ),
          const SizedBox(height: 20),

          // Share
          Obx(
                () => _buildActionButtonWithCount(
              icon: Icons.share,
              count: controller.shareCount.value,
              onPressed: controller.share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonWithCount({
    required IconData icon,
    required int count,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 24,
            ),
          ),
        ),
        if (count > 0) ...[
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}*/

class ImagePostScreen extends StatefulWidget {
  final int postId;
  ImagePostScreen({required this.postId});

  @override
  State<ImagePostScreen> createState() => _ImagePostScreenState();
}

class _ImagePostScreenState extends State<ImagePostScreen> {
  // Animation State
  bool _showHeartAnimation = false;
  Color _heartColor = Colors.white;

  void _handleDoubleTap(ImagePostController controller, int postId) {
    // 1. Toggle Like via Controller
    controller.likePost(postId, 1);

    // 2. Trigger HEART Animation in overlay
    setState(() {
      _showHeartAnimation = true;
      // If we just liked it (was false, now true), red heart.
      // If unliked (was true, now false), white broken heart or just white.
      // Logic: controller.isLiked is ALREADY toggled by likePost?
      // Actually likePost is async, but we want instant feedback.
      // Ideally we assume success.
      _heartColor = Colors.white; 
    });

    // 3. Hide animation after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Put controller with unique tag to avoid singleton method sharing across different posts
    final controller = Get.put(ImagePostController(postId: widget.postId), tag: widget.postId.toString());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.lightBackgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          final post = controller.post.value;
          if (post == null) {
            return Center(
              child: Text(
                "No Post Found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              // Main Image Area
              Positioned(
                top: 20,
                left: 12,
                right: 12,
                bottom: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onDoubleTap: () => _handleDoubleTap(controller, widget.postId),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          
                          // The Image
                          InteractiveViewer(
                            child: SizedBox.expand(
                              child: post.media.isNotEmpty
                                  ? Image.network(
                                      AppUrls.getFullImageUrl(post.media.first.url),
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        "No Media",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                            ),
                          ),

                          // Heart Animation Overlay
                           if (_showHeartAnimation)
                             TweenAnimationBuilder<double>(
                               tween: Tween(begin: 0.5, end: 1.2),
                               duration: const Duration(milliseconds: 400),
                               curve: Curves.elasticOut,
                               builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Icon(
                                      Icons.favorite,
                                      color: _heartColor,
                                      size: 110,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  );
                               },
                             ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // User Info (Bottom)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(AppUrls.getFullImageUrl(post.user.avatar)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${post.user.name} • 1st',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              post.caption ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Side Actions
              _buildSideActions(context, controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSideActions(BuildContext context, ImagePostController controller) {
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          // Like Button with Animation
          Obx(() {
            final isLiked = controller.isLiked.value;
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                     // manual toggle
                     controller.likePost(widget.postId, 1);
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isLiked),
                        color: isLiked ? Colors.red : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.likeCount.value}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            );
          }),
          const SizedBox(height: 18),
          
          // Comment Button
          Obx(
            () => _actionButton(
              icon: Icons.chat_bubble_outline,
              count: controller.commentCount.value,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (_) => CommentsBottomSheet(
                        postId: controller.post.value!.id,
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          
          // Share Button
          Obx(
            () => _actionButton(
              icon: Icons.share,
              count: controller.shareCount.value,
              onTap: controller.share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withOpacity(0.6),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}

/*
class ImagePostScreen extends StatelessWidget {
  final int postId;
  ImagePostScreen({required this.postId});
 // const JobPostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.put(JobPostController());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Stack(
          children: [
            Positioned(
              top: 20,
            //   top: kToolbarHeight -10, // appbar ke niche thoda gap
               left: 12,
               right: 12,
               bottom: 90, // bottom user info ke upar space
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.transparent,
                  child: InteractiveViewer(
                    child: SizedBox.expand(
                      child: Image.asset(
                        AppAssets.imgAppLogo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
           */
/* InteractiveViewer(
              child: Center(
                child: Image.asset(AppAssets.imgAppLogo, fit: BoxFit.contain),
              ),
            ),*/ /*

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade700,
                      child: const Text(
                        'GS',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Gopal Singh • 1st',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Training Head | DigiCoders Technologies',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '📢 We Are Hiring – Flutter Developer...',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Side Actions
            _buildSideActions(controller),
          ],
        ),
      ),
    );
  }

  /// 👇 Right Side Actions
  Widget _buildSideActions(JobPostController controller) {
    return Positioned(
      right: 12,
      bottom: 120,
      child: Column(
        children: [
          Obx(
            () => _actionButton(
              icon:
                  controller.isLiked.value
                      ? Icons.favorite
                      : Icons.favorite_border,
              count: controller.likeCount.value,
              color: controller.isLiked.value ? Colors.red : Colors.white,
              onTap: controller.toggleLike,
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => _actionButton(
              icon: Icons.chat_bubble_outline,
              count: controller.commentCount.value,
              onTap: controller.addComment,
            ),
          ),
          const SizedBox(height: 18),
          Obx(
            () => _actionButton(
              icon: Icons.share,
              count: controller.shareCount.value,
              onTap: controller.share,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black.withOpacity(0.6),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}
*/
