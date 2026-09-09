import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/expandable_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../db/shared_pref_manager.dart';
import '../../../core/helper/date_helper.dart';
import '../../messages/persentation/dashboard.dart';
import '../../profile/screen/profile_screen.dart';
import '../../quick_access/persentation/drawerScreen.dart';
import '../../story/persentation/storyfullview.dart';
import '../../subscription/persentation/profile_plans_screen.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../../subscription/data/model/profile_config_model.dart';
import '../controller/comment_controller.dart';
import '../controller/homeController.dart';
import '../controller/create_story_controller.dart';
import '../model/post_model.dart';
import '../model/story_model.dart';
import 'widgets/feed_media_widget.dart';
import '../../../core/network/app_urls.dart';
import '../../../route/app_pages.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final controller = Get.put(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final user = SharedPrefManager().user;
    final imageUrl = user?.profilePhotoPath ?? "";

    return Scaffold(
      backgroundColor: AppColors.transparent,
      key: controller.scaffoldKey,
      endDrawer: DrawerScreen(),
      endDrawerEnableOpenDragGesture: false,

      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is UserScrollNotification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (controller.showStories.value) {
                controller.showStories.value = false;
              }
            } else if (notification.direction == ScrollDirection.forward) {
              if (!controller.showStories.value) {
                controller.showStories.value = true;
              }
            }
          }

          // Pagination Logic only
          if (notification is ScrollEndNotification &&
              !controller.isLoading.value &&
              controller.isMoreDataAvailable.value &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent * 0.8) {
            controller.fetchPosts(loadMore: true);
          }
          return false;
        },
        child: Obx(() {
          final isStoriesShown = controller.showStories.value;
          return RefreshIndicator(
            color: AppColors.premiumGold,
            notificationPredicate: (notification) {
              return isStoriesShown;
            },
            onRefresh: () async {
              await controller.fetchPosts();
              await controller.fetchStories();
              await controller.fetchUnreadNotificationCount();
            },
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.imgBackgroundApp),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      Obx(
                        () {
                          final _ = controller.currentUser.value;
                          final isGold = AppColors.isGoldEligible;
                          return SliverAppBar(
                            floating: true,
                            snap: true,
                            pinned: controller.showStories.value,
                            backgroundColor: AppColors.transparent,
                            elevation: 0,
                            automaticallyImplyLeading: false,
                            toolbarHeight: 60,
                            titleSpacing: 0,
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppAssets.HomeAppLogo,
                                width: 120,
                                height: 120,
                              ),
                            ],
                          ),
                          actions: [
                            Obx(() {
                              final count =
                                  controller.unreadNotificationCount.value;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      CupertinoIcons.bell,
                                      color: AppColors.premiumGold,
                                      size: 26,
                                    ),
                                    onPressed: () async {
                                      await Get.toNamed(
                                        AppRoutes.notifications,
                                      );
                                      controller.fetchUnreadNotificationCount();
                                    },
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          child: Text(
                                            count > 99 ? '99+' : '$count',
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.wechat_outlined,
                                    color: AppColors.premiumGold,
                                    size: 26,
                                  ),
                                  onPressed: () => Get.to(dashboard()),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.menu_rounded,
                                  color: AppColors.premiumGold,
                                  size: 28,
                                ),
                                onPressed: () => controller.openDrawer(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                      // ============= STORIES SECTION (Always Visible) =============
                      SliverToBoxAdapter(
                        child: Obx(() {
                          final isGold = AppColors.isGoldEligible;
                          if (controller.isStoryLoading.value) {
                            return _buildStoriesShimmer();
                          }

                          // Identify My Story vs Others
                          final currentUserId =
                              controller.currentUser.value?.id;
                          UserStoryGroup? myStoryGroup;
                          List<UserStoryGroup> otherStories = [];

                          if (currentUserId != null) {
                            // Split existing stories
                            for (var group in controller.storyData) {
                              if (group.user.id == currentUserId ||
                                  (group.stories.isNotEmpty &&
                                      group.stories.first.is_mine)) {
                                myStoryGroup = group;
                              } else {
                                otherStories.add(group);
                              }
                            }
                          } else {
                            otherStories = List.from(controller.storyData);
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: controller.showStories.value ? 130 : 0,
                            curve: Curves.easeInOut,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: controller.showStories.value ? 1.0 : 0.0,
                              child: Container(
                                height: 130,
                                decoration: isGold
                                    ? const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            AppAssets.imgStoryBackground,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null,
                                color: isGold ? null : AppColors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount:
                                      otherStories.length +
                                      1, // +1 for "Your Story"
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return _buildMyStoryItem(
                                        imageUrl,
                                        myStoryGroup,
                                      );
                                    }

                                    final story = otherStories[index - 1];

                                    // Double-check: Skip if this is somehow the current user's story
                                    if (story.user.id == currentUserId ||
                                        (story.stories.isNotEmpty &&
                                            story.stories.first.is_mine)) {
                                      return SizedBox.shrink(); // Don't show duplicate
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => FullScreenStoryViewer(
                                            stories: story.stories,
                                            initialIndex: 0,
                                          ),
                                        );
                                      },
                                      child: _buildStoryCard(
                                        story, // Pass full story object
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      // ============= POSTS SECTION =============
                      Obx(() {
                        if (controller.isLoading.value &&
                            controller.posts.isEmpty) {
                          return _buildPostsShimmer();
                        }

                        if (controller.posts.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: AppColors.premiumGold,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "No Posts Available",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.premiumGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final post = controller.posts[index];
                            return _buildModernPostCard(post, index, context);
                          }, childCount: controller.posts.length),
                        );
                      }),

                      // ============= LOADING MORE =============
                      Obx(() {
                        return controller.isMoreDataAvailable.value
                            ? SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                            : SliverToBoxAdapter(child: SizedBox.shrink());
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoriesShimmer() {
    final isGold = AppColors.isGoldEligible;
    return Container(
      height: 130,
      decoration: isGold
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.imgStoryBackground),
                fit: BoxFit.cover,
              ),
            )
          : null,
      color: isGold ? null : AppColors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Shimmer.fromColors(
              baseColor: AppColors.premiumGold.withOpacity(0.3),
              highlightColor: AppColors.premiumGold.withOpacity(0.1),
              child: Container(
                width: 80,
                height: 114,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Avatar + Name)
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.premiumGold.withOpacity(0.3),
                    highlightColor: AppColors.premiumGold.withOpacity(0.1),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: AppColors.premiumGold.withOpacity(0.3),
                        highlightColor: AppColors.premiumGold.withOpacity(0.1),
                        child: Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer.fromColors(
                        baseColor: AppColors.premiumGold.withOpacity(0.3),
                        highlightColor: AppColors.premiumGold.withOpacity(0.1),
                        child: Container(
                          width: 80,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Media Area (Large rectangle)
              Shimmer.fromColors(
                baseColor: AppColors.premiumGold.withOpacity(0.3),
                highlightColor: AppColors.premiumGold.withOpacity(0.1),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Actions (Like, Comment, Share icons placeholder)
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: AppColors.premiumGold.withOpacity(0.3),
                    highlightColor: AppColors.premiumGold.withOpacity(0.1),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Shimmer.fromColors(
                    baseColor: AppColors.premiumGold.withOpacity(0.3),
                    highlightColor: AppColors.premiumGold.withOpacity(0.1),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }, childCount: 3),
    );
  }

  // ============= ADD STORY BUTTON =============
  // ============= MY STORY ITEM (Index 0) =============
  // ============= MY STORY ITEM (Index 0) =============
  // ============= MY STORY ITEM (Index 0) =============
  Widget _buildMyStoryItem(String userAvatar, UserStoryGroup? myStoryGroup) {
    bool hasStory = myStoryGroup != null && myStoryGroup.stories.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (myStoryGroup != null && myStoryGroup.stories.isNotEmpty) {
          // View own story
          Get.to(
            () => FullScreenStoryViewer(
              stories: myStoryGroup.stories,
              initialIndex: 0,
            ),
          );
        } else {
          // Add new story
          final storyController = Get.put(StoryController());
          storyController.showPickerOptions();
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient:
              hasStory
                  ? LinearGradient(
                    colors: [
                      AppColors.premiumGold,
                      AppColors.goldHighlight,
                      AppColors.goldGlow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: !hasStory ? AppColors.secondaryBackground : null,
        ),
        padding: hasStory ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.mainBackground, // Inner dark color
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Media
                if (hasStory)
                  _buildStoryMedia(myStoryGroup.stories.last)
                else
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.premiumGold.withOpacity(0.05),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.15),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                // Dark Gradient for Text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.mainBackground.withOpacity(0.75),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Text
                Positioned(
                  bottom: 8,
                  left: 6,
                  right: 6,
                  child: Text(
                    hasStory ? "Your Story" : "Add Story",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.premiumGold,
                          AppColors.goldHighlight,
                          AppColors.goldGlow,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasStory)
                          const Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 10,
                          ),
                        if (!hasStory) const SizedBox(width: 2),
                        Text(
                          hasStory ? "Story" : "Add",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Plus Button to add more stories when they already have active stories
                if (hasStory)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () {
                        final storyController = Get.put(StoryController());
                        storyController.showPickerOptions();
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.white.withOpacity(0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ), // Close inner Container
        ),
      ),
    );
  }

  // ============= STORY CARD (OTHERS) =============
  Widget _buildStoryCard(UserStoryGroup story) {
    bool hasUnseen = story.hasUnseen;
    String name = story.user.name;
    // Safety check for name
    if (story.user.id == controller.currentUser.value?.id ||
        (story.stories.isNotEmpty && story.stories.first.is_mine)) {
      name = "Your Story";
    }

    return GestureDetector(
      onTap:
          () => Get.to(
            () =>
                FullScreenStoryViewer(stories: story.stories, initialIndex: 0),
          ),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient:
              hasUnseen
                  ? LinearGradient(
                    colors: [
                      AppColors.premiumGold,
                      AppColors.goldHighlight,
                      AppColors.goldGlow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: !hasUnseen ? AppColors.secondaryBackground : null,
        ),
        padding: hasUnseen ? const EdgeInsets.all(2.0) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.mainBackground, // Inner dark color
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Media
                story.stories.isNotEmpty
                    ? _buildStoryMedia(story.stories.last)
                    : _buildUserAvatar(story.user.avatar),

                // Dark Gradient for Text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.mainBackground.withOpacity(0.75),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Text
                Positioned(
                  bottom: 8,
                  left: 6,
                  right: 6,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge
                if (hasUnseen)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.premiumGold,
                            AppColors.goldHighlight,
                            AppColors.goldGlow,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "New",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ), // Close inner Container
        ),
      ),
    );
  }

  // Helper to build robust media preview
  Widget _buildStoryMedia(StoryModel story) {
    // 1. Try Thumbnail
    if (story.thumbnailUrl.isNotEmpty) {
      return Image.network(
        story.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildErrorFallback(story.type),
      );
    }

    // 2. Try Media URL if Image
    if (story.type == 'image' && story.mediaUrl.isNotEmpty) {
      return Image.network(
        story.mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildErrorFallback(story.type),
      );
    }

    // 3. Fallback for Video without thumbnail or Error
    return _buildErrorFallback(story.type);
  }

  Widget _buildUserAvatar(String? avatarUrl) {
    final bool hasValid = avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        avatarUrl != "null" &&
        !avatarUrl.contains("ui-avatars.com");
    if (hasValid) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (ctx, err, stack) => Container(
              color: AppColors.secondaryBackground,
              child: Icon(Icons.person, color: AppColors.premiumGold),
            ),
      );
    }
    return Container(
      color: AppColors.secondaryBackground,
      child: Icon(Icons.person, color: AppColors.premiumGold),
    );
  }

  Widget _buildErrorFallback(String type) {
    return Container(
      color: AppColors.premiumGold,
      child: Center(
        child: Icon(
          type == 'video' ? Icons.videocam : Icons.broken_image,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  // ============= MODERN POST CARD =============
  Widget _buildModernPostCard(PostItem post, int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface, // Dark surface
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== POST HEADER ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap:
                        () => Get.to(
                          ProfileScreen(viewUserName: post.user.username),
                        ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryBackground,
                        border: Border.all(
                          color: AppColors.premiumGold.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            (post.user.avatar != null &&
                                    post.user.avatar!.isNotEmpty &&
                                    post.user.avatar != "null" &&
                                    !post.user.avatar!.contains("ui-avatars.com"))
                                ? Image.network(
                                  AppUrls.getFullImageUrl(post.user.avatar!),
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: AppColors.premiumGold,
                                        size: 24,
                                      ),
                                )
                                : Icon(
                                  Icons.person,
                                  color: AppColors.premiumGold,
                                  size: 24,
                                ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  // Name, Occupation & Song
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap:
                                    () => Get.to(
                                      ProfileScreen(
                                        viewUserName: post.user.username,
                                      ),
                                    ),
                                child: Text(
                                  post.user.username.isNotEmpty
                                      ? post.user.username
                                      : post.user.name,
                                  style: TextStyle(
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
                              SizedBox(width: 4),
                              Image.asset(
                                AppAssets.imgverified,
                                height: 16,
                                width: 16,
                                color: AppColors.successSoftGold,
                              ),
                              //Icon(Icons.verified, color: Colors.blue, size: 14),
                            ],

                            // Date / Time
                            Text(
                              " • ${DateHelper.formatPostDate(post.createdAt)}",
                              style: TextStyle(
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
                                Icon(
                                  Icons.music_note,
                                  size: 12,
                                  color: AppColors.premiumGold,
                                ),
                                SizedBox(width: 4),
                              ],

                              Flexible(
                                child: Text(
                                  post.type == 'video'
                                      ? "Original Audio"
                                      : post.user.occupation,
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

                  // Follow Button
                  if (!post.is_mine) ...[
                    SizedBox(width: 8),
                    Obx(() {
                      final isFollowing =
                          controller.followController
                              .isUserFollowing(
                                post.user.id,
                                initialValue: post.is_following,
                              )
                              .value;

                      // If following, you can choose to hide it or show "Following"
                      // User said "update nhi ho rhi", implying they want to see the change.
                      // Let's show "Following" in a subtle way or allow hiding if intended.
                      // Given previous logic was hiding it (line 445), let's keep it visible
                      // but reactive so it can vanish/change smoothly.

                      final bool following = isFollowing;

                      return GestureDetector(
                        onTap: () {
                          if (post.user.id != null) {
                            controller.toggleFollowForPostUser(post.user.id!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                following
                                    ? AppColors.secondaryBackground
                                    : AppColors.transparent,
                            border: Border.all(
                              color: AppColors.premiumGold,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            following ? "Following" : "Follow",
                            style: TextStyle(
                              color: AppColors.premiumGold,
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
                    icon: Icon(Icons.more_horiz, color: AppColors.primaryText),
                    onPressed:
                        () => _showSideMenu(
                          context,
                          post.id,
                          post.user.username,
                          post.user.id,
                        ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
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
              ),

            // ========== POST ACTIONS ==========
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Like
                      GestureDetector(
                        onTap: () => controller.likePost(post.id, index),
                        child: Icon(
                          post.stats.isLiked == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              post.stats.isLiked == true
                                  ? Colors.red
                                  : AppColors.premiumGold,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 4),
                      if ((post.stats.likeCount ?? 0) > 0)
                        Text(
                          "${post.stats.likeCount}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.premiumGold,
                          ),
                        ),

                      SizedBox(width: 16),

                      // Comment
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: AppColors.transparent,
                            builder:
                                (_) => CommentsBottomSheet(postId: post.id),
                          );
                        },
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.premiumGold,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 4),
                      if ((post.stats.commentCount ?? 0) > 0)
                        Text(
                          "${post.stats.commentCount}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.premiumGold,
                          ),
                        ),

                      SizedBox(width: 16),

                      // Share
                      GestureDetector(
                        onTap: () {
                          final link =
                              "https://ivatan.in/post/${post.id}?type=${post.media.first.type}";
                          Share.share("Check this post 👇\n$link");
                        },
                        child: Icon(
                          Icons.share,
                          color: AppColors.premiumGold,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 4),
                      if ((post.stats.shareCount ?? 0) > 0)
                        Text(
                          "${post.stats.shareCount}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.premiumGold,
                          ),
                        ),

                      Spacer(),

                      GestureDetector(
                        onTap: () => controller.toggleBookmark(post.id),
                        child: Icon(
                          post.stats.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: AppColors.premiumGold,
                          size: 26,
                        ),
                      ),
                    ],
                  ),

                  // Like Count
                  // if ((post.stats.likeCount ?? 0) > 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8),
                  //     child: Text(
                  //       "${post.stats.likeCount} likes",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 13,
                  //         color: AppColors.white,
                  //       ),
                  //     ),
                  //   ),

                  // Caption with Username + Rich Text
                  if (post.caption != null && post.caption!.isNotEmpty) ...[
                    SizedBox(height: 6),
                    ExpandableCaption(
                      text: post.caption!,
                      textColor: AppColors.primaryText,
                      username:
                          post.user.username.isNotEmpty
                              ? post.user.username
                              : post.user.name,
                      onUsernameTap:
                          () => Get.to(
                            ProfileScreen(viewUserName: post.user.username),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ), // Close ClipRRect
    ); // Close Container
  }

  void _showSideMenu(
    BuildContext context,
    int postId,
    String username,
    int userId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: AppColors.premiumGold),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 6),
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
                    leading: Icon(
                      Icons.report_gmailerrorred_outlined,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      "Report",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.openReportBottomSheet(postId: postId);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.premiumGold,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // 2. About this profile
                  ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.white,
                    ),
                    title: Text(
                      "About this profile",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (username.isNotEmpty) {
                        Get.to(ProfileScreen(viewUserName: username));
                      }
                    },
                  ),

                  // 3. Block
                  ListTile(
                    leading: Icon(Icons.block, color: Colors.redAccent),
                    title: Text(
                      "Block",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.blockUser(userId);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.premiumGold,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // 4. Interested
                  ListTile(
                    leading: Icon(
                      Icons.star_border_rounded,
                      color: AppColors.white,
                    ),
                    title: Text(
                      "Interested",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.markInterested(postId);
                    },
                  ),

                  // 5. Not Interested
                  ListTile(
                    leading: Icon(
                      Icons.visibility_off_outlined,
                      color: AppColors.white,
                    ),
                    title: Text(
                      "Not interested",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.markNotInterested(postId);
                    },
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}

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
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false, // Allows clicks outside the sheet to dismiss it
        builder: (_, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.premiumGold),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),

              child: Column(
                children: [
                  /// --- HEADER ----
                  _buildHeader(),

                  Divider(height: 1, color: AppColors.premiumGold),

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
                          return _buildMainComment(
                            comment,
                            index,
                            widget.postId,
                          );
                        },
                      );
                    }),
                  ),

                  /// --- COMMENT INPUT FIELD ----
                  _buildInputField(),
                ],
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
              color: AppColors.premiumGold,
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
                        color: AppColors.white,
                      ),
                    ),
                    Obx(
                      () => Text(
                        "${commentController.commentsList.length} ${commentController.commentsList.length == 1 ? 'comment' : 'comments'}",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.premiumGold,
                        ),
                      ),
                    ),
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
              color: AppColors.premiumGold,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 50,
              color: AppColors.premiumGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No comments yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.premiumGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Be the first to share your thoughts!",
            style: TextStyle(fontSize: 14, color: AppColors.premiumGold),
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
              color: AppColors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryBackground,
                          border: Border.all(
                            color: AppColors.premiumGold.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              (comment.user?.avtar != null &&
                                      comment.user!.avtar!.isNotEmpty &&
                                      comment.user!.avtar != "null" &&
                                      !comment.user!.avtar!.contains("ui-avatars.com"))
                                  ? Image.network(
                                    AppUrls.getFullImageUrl(
                                      comment.user!.avtar!,
                                    ),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          color: AppColors.premiumGold,
                                          size: 24,
                                        ),
                                  )
                                  : Icon(
                                    Icons.person,
                                    color: AppColors.premiumGold,
                                    size: 24,
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
                                color: AppColors.white,
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
                            color: AppColors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action buttons
                        Row(
                          children: [
                            _buildActionButton(
                              icon:
                                  comment.hasLiked == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                              label: "${comment.likesCount}",
                              color:
                                  comment.hasLiked
                                      ? Colors.red
                                      : AppColors.premiumGold,
                              onTap: () {
                                commentController.likeComment(
                                  comment.id,
                                  index,
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            _buildActionButton(
                              icon: Icons.reply_rounded,
                              label: "Reply",
                              color: AppColors.premiumGold,
                              onTap: () {
                                setState(() {
                                  replyingToCommentId = comment.id;
                                  replyingToUsername = comment.user?.username;
                                });
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              },
                            ),
                            if (comment.replies.isNotEmpty) ...[
                              const SizedBox(width: 20),
                              Text(
                                "${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.premiumGold,
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
                children:
                    comment.replies.asMap().entries.map<Widget>((entry) {
                      int replyIndex = entry.key;
                      var reply = entry.value;
                      return _buildReply(
                        reply,
                        index,
                        replyIndex,
                        widget.postId,
                      );
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
        padding: const EdgeInsets.only(
          left: 16,
          top: 12,
          right: 16,
          bottom: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.premiumGold,
              ),
              child: ClipOval(
                child:
                    (reply.user?.avtar != null &&
                            reply.user!.avtar!.isNotEmpty &&
                            reply.user!.avtar != "null")
                        ? Image.network(
                          AppUrls.getFullImageUrl(reply.user!.avtar!),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Icon(
                                Icons.person,
                                color: AppColors.black,
                                size: 20,
                              ),
                        )
                        : Icon(Icons.person, color: AppColors.black, size: 20),
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
                      color: AppColors.white,
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
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (customIcon != null)
            customIcon
          else if (icon != null)
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
    final List<String> quickEmojis = [
      "❤️",
      "🔥",
      "👏",
      "😂",
      "😮",
      "😍",
      "😢",
      "🙌",
      "👍",
    ];

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(1.0),
        border: Border(top: BorderSide(color: AppColors.premiumGold, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick Emojis Row
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quickEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    textController.text =
                        textController.text + quickEmojis[index];
                    textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: textController.text.length),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      quickEmojis[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: AppColors.premiumGold),

          // Replying indicator
          if (replyingToCommentId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.premiumGold,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            replyingToCommentId != null
                                ? "Write a reply..."
                                : "Share your thoughts...",
                        hintStyle: TextStyle(
                          color: AppColors.white,
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
                        // Do not pop, just clear so user can comment again or see result
                        // Navigator.pop(context, commentController.commentsList.length);
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
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
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
      builder:
          (_) => GestureDetector(
            onTap: () {
              blurEntry.remove();
              popupEntry.remove();
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: AppColors.white.withOpacity(0.4)),
            ),
          ),
    );

    popupEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx - 80,
          top: position.dy - 10,
          child: Material(
            color: AppColors.transparent,
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
                    commentController.commentsList[commentIndex].replies
                        .removeAt(replyIndex);
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
                    Icon(
                      Icons.delete_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: AppColors.white,
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

// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:i_vatan_app/core/constants/app_assets.dart';
// import 'package:i_vatan_app/core/theme/app_colors.dart';
// import 'package:i_vatan_app/db/shared_pref_manager.dart';
// import 'package:i_vatan_app/features/dashboard/controller/create_story_controller.dart';
// import 'package:i_vatan_app/features/dashboard/persentation/settings_page.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../../../core/helper/expandable_text.dart';
// import '../../../core/network/app_urls.dart';
// import '../../messages/persentation/dashboard.dart';
// import '../../messages/persentation/message_screen.dart';
// import '../../post/presentation/image_post_screen.dart';
// import '../../profile/screen/profile_screen.dart';
// import '../../quick_access/persentation/drawerScreen.dart';
// import '../../story/persentation/storyfullview.dart';
// import '../../videos/persentation/play_video_screen.dart';
// import '../controller/comment_controller.dart';
// import '../controller/follow_controller.dart';
// import '../controller/homeController.dart';
// import '../controller/navigationController.dart';
// import '../model/post_model.dart';
// import 'full_image_viewer.dart';
//
// class HomePage extends StatelessWidget {
//   HomePage({Key? key}) : super(key: key);
//   final controller = Get.put(HomeController(), permanent: true);
//
//   @override
//   Widget build(BuildContext context) {
//     final StoryController storyController = Get.put(StoryController());
//    // final HomeController controller = Get.find<HomeController>();
//     final FollowController followController = Get.put(FollowController());
//     final user = SharedPrefManager().user;
//     final imageUrl = user?.profilePhotoPath ?? "";
//     final String name = user?.name ?? "Guest User";
//     final token = user?.token;
//     final user_id = user?.id;
//     //final controller = Get.put(HomeController(), permanent: true);
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(Duration(seconds: 1), () {
//         controller.showWelcomeDialog(context);
//       });
//     });
//
//     print("profilePhotoPath : "+AppUrls.imageurl+imageUrl);
//
//     return Container(
//       /*decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF7AB6F0),
//             Color(0xFFB3E5F5),
//             Color(0xFFFFFFFF),
//             Color(0xFFFFFFFF),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),*/
//       child:
//       Scaffold(
//         backgroundColor: AppColors.black,
//         key: controller.scaffoldKey, // 🔥 MOST IMPORTANT
//         endDrawer: DrawerScreen(), // your drawer file
//         endDrawerEnableOpenDragGesture: false,
//         appBar: AppBar(
//           backgroundColor: AppColors.transparent,
//           elevation: 0,
//         //  titleSpacing: 12,
//           leadingWidth: 60,
//           /*leading: Padding(
//             padding: const EdgeInsets.only(left: 13), // ⭐ leading me margin
//             child: GestureDetector(
//               onTap: () {
//                 Get.to(ProfileScreen());
//               },
//               child: Container(
//                // width: 70,
//                // height: 40,
//                 // decoration: BoxDecoration(
//                 //   border: Border.all(color: Colors.blue, width: 2),
//                 //   borderRadius: BorderRadius.only(
//                 //     topLeft: Radius.circular(15),
//                 //     topRight: Radius.circular(15),
//                 //     bottomLeft: Radius.circular(15),
//                 //     bottomRight: Radius.circular(15),
//                 //   ),
//                 // ),
//                 child:
//                 // Obx(() {
//                 //   final user = controller.currentUser.value;
//                 //   final imageUrl = user?.profilePhotoPath ?? "";
//                 //
//                 //   print("b vd iugednmv suif wf e : "+AppUrls.imageurl + imageUrl);
//                 //
//                 //   return Image.network(
//                 //     imageUrl.isNotEmpty
//                 //         ? AppUrls.imageurl + imageUrl
//                 //         : "https://i.pravatar.cc/150?img=10",
//                 //     fit: BoxFit.cover,
//                 //   );
//                 // })
//                 *//*ClipRRect(
//                 //  borderRadius: BorderRadius.circular(15),
//                   child: Image.network(
//                     imageUrl.isNotEmpty
//                         ? AppUrls.imageurl+imageUrl
//                         : "https://i.pravatar.cc/150?img=10",
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Image.asset(
//                         AppAssets.imgAppLogo,   // 👈 YOUR ASSET IMAGE
//                         fit: BoxFit.cover,
//                       );
//                     },
//                   ),
//
//                 ),*//*
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: AppColors.premiumGold,
//                   child: ClipOval(
//                     child: SizedBox(
//                       width: 40,
//                       height: 40,
//                       child: Image.network(
//                         imageUrl.isNotEmpty
//                             ? AppUrls.imageurl + imageUrl
//                             : "https://i.pravatar.cc/150?img=10",
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Image.asset(
//                             AppAssets.imgAppLogo,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),*/
//           title: Text(
//            // name.toString(),
//           "  i-app",
//             style: const TextStyle(
//               color: AppColors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12), // ⭐ actions me margin
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.message, color: AppColors.white),
//                     onPressed: () {
//                       Get.to(dashboard());
//                     },
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.menu_open_outlined,
//                       color: AppColors.white,
//                     ),
//                     onPressed: () {
//                       controller.openDrawer();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: NotificationListener<ScrollNotification>(
//           onNotification: (scroll) {
//             if (scroll.metrics.pixels > 50) {
//               controller.showStories.value = true;
//             }
//             if (!controller.isLoading.value &&
//                 controller.isMoreDataAvailable.value &&
//                 scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
//               controller.fetchPosts(loadMore: true);
//             }
//
//             return true;
//           },
//           child: RefreshIndicator(color: AppColors.white,
//             onRefresh: () async {
//               await controller.fetchPosts();
//               await controller.fetchStories();
//             },
//             child: CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Obx(() {
//                     if (!controller.showStories.value) return SizedBox.shrink();
//                     if (controller.isStoryLoading.value) {
//                       return SizedBox(
//                         height: 80,
//                         child: Center(child: CircularProgressIndicator()),
//                       );
//                     }
//
//                     return SizedBox(
//                       height: 90,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         itemCount: controller.storyData.length + 1,
//                         itemBuilder: (context, index) {
//                           // Add Story Button
//                           if (index == 0) {
//                             return GestureDetector(
//                               onTap: () {
//                                 storyController.showPickerOptions();
//                               },
//                               child: _buildAddStory(imageUrl),
//                             );
//                           }
//                           final storyIndex = index - 1;
//                           final story = controller.storyData[storyIndex];
//
//                           return GestureDetector(
//                             onTap: () {
//                               Get.to(() => FullScreenStoryViewer(
//                                 stories: story.stories,
//                                 initialIndex: 0,
//                               ));
//                             },
//                             child: _buildStoryItem(
//                               story.user.name,
//                               story.user.avatar ?? "",
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ),
//
//                 /// ================= POSTS =================
//                 Obx(() {
//                   if (controller.isLoading.value && controller.posts.isEmpty) {
//                     return const SliverFillRemaining(
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   }
//
//                   if (controller.posts.isEmpty) {
//                     return const SliverFillRemaining(
//                       child: Center(child: Text("No Posts Available")),
//                     );
//                   }
//
//                   return SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                         final post = controller.posts[index];
//                         final mediaUrl = post.media.isNotEmpty
//                             ? post.media.first.thumbnail
//                             : "";
//
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 15, vertical: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//
//                               /// ================= HEADER =================
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   /// Avatar
//                                   GestureDetector(
//                                     onTap: () {
//                                       Get.to(ProfileScreen(viewUserName: post.user.username,));
//                                       // final nav = Get.find<NavigationController>();
//                                       // nav.changePage(4, username: post.user.username);
//                                     },
//                                     child:Container(
//                                       width: 40,
//                                       height: 40,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         gradient: LinearGradient(
//                                           colors: [Colors.orange.shade400, Colors.pink.shade500],
//                                         ),
//                                       ),
//                                       child:  CircleAvatar(
//                                         radius: 20,
//                                         backgroundColor: AppColors.premiumGold,
//                                         backgroundImage: post.user.avatar != null &&
//                                             post.user.avatar!.isNotEmpty
//                                             ? NetworkImage(post.user.avatar!)
//                                             : const AssetImage(AppAssets.imgAppLogo)
//                                         as ImageProvider,
//                                       ),
//                                     ),
//
//                                   ),
//
//                                   const SizedBox(width: 12),
//
//                                   /// Name + Interests (ONLY THIS SHOULD EXPAND)
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         InkWell(
//                                           onTap: (){
//                                             Get.to(ProfileScreen(viewUserName: post.user.username,));
//                                           },
//                                           child: Row(
//                                             children: [
//                                               Text(
//                                                 post.user.name,
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 14,
//                                                   color: AppColors.white
//                                                 ),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               if (post.user.isVerified)
//                                                 const Padding(
//                                                   padding: EdgeInsets.only(left: 4),
//                                                   child: Icon(
//                                                     Icons.verified,
//                                                     color: Colors.blue,
//                                                     size: 16,
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                         //const SizedBox(height: 2),
//                                         Text(
//                                           post.user.occupation ,
//                                           style: const TextStyle(
//                                             fontSize: 11,
//                                             color: AppColors.white,
//                                           ),
//                                          // maxLines: 1,
//                                          // overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//
//                                   /// Follow Button (Fixed width)
//                                   if (!post.is_mine) ...[
//                                     const SizedBox(width: 8),
//                                     GestureDetector(
//                                       onTap: () {
//                                         if (post.user.id != null) {
//                                           controller.toggleFollowForPostUser(post.user.id!);
//                                         }
//                                       },
//                                       child: Container(
//                                         padding:
//                                         const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: AppColors.white),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                         child: Text(
//                                           post.is_following ? "Following" : "Follow",
//                                           style: const TextStyle(
//                                             color: AppColors.white,
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//
//                                   /// More Icon (ALWAYS RIGHT ALIGNED)
//                                   const SizedBox(width: 6),
//                                   GestureDetector(
//                                     onTapDown: (details) {
//                                       _showSideMenu(context, details.globalPosition,post.id);
//                                     },
//                                     child: const Icon(Icons.more_vert, color: AppColors.white),
//                                   ),
//                                 ],
//                               ),
//
//
//                               const SizedBox(height: 10),
//
//                               /// ================= MEDIA =================
//                               if (mediaUrl.isNotEmpty)
//                                 GestureDetector(
//                                   onTap: () {
//                                     if (post.type == "video") {
//                                       Get.to(() => VideoPlayerScreen(
//                                         videoUrl: post.media.first.url,
//                                         videoId: post.id,
//                                       ));
//                                     }
//                                       else if (post.media.first.type == "reel") {
//                                         //  Get.to(() => ReelPlayerScreen(url: item.media.first.url));
//                                       }
//                                       else if (post.media.first.type == "image") {
//                                         Get.to(()=>ImagePostScreen(postId: post.id,));
//                                         //  Get.to(() => ImagePreviewScreen(url: item.media.first.url));
//                                       }
//                                   },
//                                   onDoubleTap: () {
//                                     controller.likePost(post.id, index);
//                                   },
//                                   child: Stack(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(24),
//                                         child: Image.network(
//                                           mediaUrl,
//                                           height: 350,
//                                           width: double.infinity,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (context, error, stack) {
//                                             return Image.asset(
//                                               AppAssets.imgOnbording3,
//                                               height: 250,
//                                               width: double.infinity,
//                                               fit: BoxFit.cover,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       if (post.type == "video")
//                                         Positioned(
//                                           top: 10,
//                                           right: 10,
//                                           child: Icon(
//                                             Icons.videocam_rounded,
//                                             color: AppColors.white,
//                                             size: 28,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//
//                               const SizedBox(height: 10),
//
//                               /// ================= ACTIONS =================
//                               Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       controller.likePost(post.id, index);
//                                     },
//                                     child: Icon(
//                                       post.stats.isLiked == true
//                                           ? Icons.favorite
//                                           : Icons.favorite_border,
//                                       color: post.stats.isLiked == true
//                                           ? Colors.red
//                                           : AppColors.premiumGold,
//                                     ),
//                                   ),
//
//                                   const SizedBox(width: 4),
//                                   Text("${post.stats.likeCount ?? 0}",style: TextStyle(color: AppColors.white), ),
//
//                                   const SizedBox(width: 20),
//
//                                   GestureDetector(
//                                     onTap: () {
//                                       showModalBottomSheet(
//                                         context: context,
//                                         isScrollControlled: true,
//                                         backgroundColor: AppColors.transparent,
//                                         builder: (_) => CommentsBottomSheet(
//                                           postId: post.id,
//                                         ),
//                                       );
//                                     },
//                                     child: const Icon(Icons.message, color: AppColors.white),
//                                   ),
//
//                                   const SizedBox(width: 4),
//                                   Text("${post.stats.commentCount ?? 0}",style: TextStyle(color: AppColors.white)),
//
//                                   const SizedBox(width: 20),
//
//                                   GestureDetector(
//                                     onTap: () {
//                                         final link = "https://ivatan.in/post/${post.id}?type=${post.media.first.type}";
//                                           //  "${post.id}?type=${post.media.first.type}";
//                                         Share.share("Check this post 👇\n$link");
//                                     },
//                                     child: Image.asset(AppAssets.imgShare,height: 24,width: 24,color: AppColors.white,)
//                                   ),
//
//                                   const SizedBox(width: 4),
//                                   Text("${post.stats.shareCount ?? 0}",style: TextStyle(color: AppColors.white)),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 10),
//                               ExpandableCaption(text: post.caption ?? ""),
//
//                               // Text(
//                               //   post.caption ?? "",
//                               //   style:
//                               //   const TextStyle(fontSize: 14, height: 1.4,color: AppColors.white),
//                               // ),
//                             ],
//                           ),
//                         );
//                       },
//                       childCount: controller.posts.length,
//                     ),
//                   );
//                 }),
//
//                 /// ================= LOADER (pagination bottom) =================
//                 Obx(() {
//                   return controller.isMoreDataAvailable.value
//                       ? SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Center(child: CircularProgressIndicator()),
//                     ),
//                   )
//                       : SliverToBoxAdapter(child: SizedBox.shrink());
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildPostItem({
//     required String name,
//     required String time,
//     required String imageUrl,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Container(
//         margin: const EdgeInsets.only(top: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // HEADER ----------
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundImage: NetworkImage(
//                       'https://i.pravatar.cc/150?img=8',
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               name,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.white,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: const Text(
//                                 'Follow',
//                                 style: TextStyle(color: AppColors.white),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           time,
//                           style: const TextStyle(
//                             color: AppColors.premiumGold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   IconButton(
//                     icon: const Icon(Icons.more_vert),
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//             ),
//
//             // IMAGE ----------
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Image.network(
//                 imageUrl,
//                 width: double.infinity,
//                 height: 200,
//                 fit: BoxFit.cover,
//               ),
//             ),
//
//             // ACTIONS ----------
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 children: const [
//                   Icon(Icons.favorite_border),
//                   SizedBox(width: 15),
//                   Icon(Icons.message),
//                   SizedBox(width: 15),
//                   Icon(Icons.share),
//                 ],
//               ),
//             ),
//
//             // CAPTION ----------
//             const Text(
//               'It is a long established fact that a reader...',
//               style: TextStyle(fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddStory(String imageUrl) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 12),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors:
//                     //story['isNew'] == true
//                         //?
//                     [Colors.purple, Colors.pink]
//                       //  :[Colors.orange, Colors.pink],
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(3), // border thickness
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: AppColors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: ClipOval(
//                       child: Image.network(
//                         imageUrl.isNotEmpty
//                             ? AppUrls.imageurl + imageUrl
//                             : "https://i.pravatar.cc/150?img=10",
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Image.asset(
//                             AppAssets.imgAppLogo,
//                             fit: BoxFit.cover,
//                           );
//                         },
//                       ),
//
//                     ),
//                   ),
//                 ),
//               ),
//
//              // if (story['isNew'] == true)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     width: 20,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: AppColors.white, width: 2),
//                     ),
//                     child: const Icon(
//                       Icons.add,
//                       color: AppColors.white,
//                       size: 12,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "Your story",
//             style: const TextStyle(fontSize: 12,color: AppColors.primaryDark,fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//      /* Padding(
//       padding: const EdgeInsets.only(right: 12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               shape: BoxShape.circle,
//               //    border: Border.all(color: AppColors.premiumGold, width: 2),
//             ),
//             child: const Icon(Icons.add, color: AppColors.white),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Your story',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.blueAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );*/
//   }
//
//   Widget _buildStoryItem(String name, String imageUrl) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 12),
//       child: Column(
//         children: [
//           Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors:
//                     //story['isNew'] == true
//                      //   ? [Colors.purple, Colors.pink]
//                        // :
//                     [Colors.orange, Colors.pink],
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(3), // border thickness
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: AppColors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: ClipOval(
//                       child: Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return const Center(child: CircularProgressIndicator());
//                         },
//                         errorBuilder: (_, __, ___) => const Icon(Icons.error),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           const SizedBox(height: 4),
//           Text(
//             name,
//             style: const TextStyle(fontSize: 12,color: AppColors.white,fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//
//       /*Padding(
//       padding: const EdgeInsets.only(right: 12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.blue, width: 2),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//                 bottomLeft: Radius.circular(15),
//                 bottomRight: Radius.circular(15),
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Image.network(imageUrl, fit: BoxFit.cover),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             name,
//             style: const TextStyle(fontSize: 11, color: AppColors.white),
//           ),
//         ],
//       ),
//     );*/
//   }
//
//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.flag_outlined),
//                 title: const Text('Report'),
//                 onTap: () => Navigator.pop(context),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.bookmark_outline),
//                 title: const Text('Save'),
//                 onTap: () => Navigator.pop(context),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.block_outlined),
//                 title: const Text('Block'),
//                 onTap: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _showSideMenu(BuildContext context, Offset position,int postId) {
//     showMenu(
//       context: context,
//       position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
//       items: [
//          PopupMenuItem(
//           child: InkWell(
//             onTap: (){
//               controller.openReportBottomSheet(postId:postId);
//             },
//             child: ListTile(
//               leading: Icon(Icons.flag_outlined),
//               title: Text("Report"),
//             ),
//           ),
//         ),
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.bookmark_border),
//             title: Text("Save"),
//           ),
//         ),
//         const PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.block_outlined),
//             title: Text("Block"),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// class LoopHomeScreen extends StatelessWidget {
//   const LoopHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       backgroundColor: AppColors.transparent,
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Column(
//               children: [
//                 // Header
//                 _buildHeader(),
//
//                 // Stories Section
//                 _buildStories(),
//
//                 // Feed
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _buildPost(
//                         username: 'mindcast',
//                         verified: true,
//                         likes: '107k',
//                         time: '12h ago',
//                       ),
//                       _buildPost(
//                         username: 'moodrealms',
//                         verified: true,
//                         likes: '89k',
//                         time: '5h ago',
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // bottomNavigationBar: _buildBottomNavigation(context),
//     );
//
//   }
//
//   // Header Widget
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'I - Vatan',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: AppColors.white
//               ,
//             ),
//           ),
//           Row(
//             children: [
//               const Icon(Icons.notifications,color: AppColors.white, size: 28),
//               const SizedBox(width: 16),
//               Stack(
//                 children: [
//                   const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Text(
//                         '3',
//                         style: TextStyle(
//                           color: AppColors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Stories Widget
//   Widget _buildStories() {
//     final stories = [
//       {'name': 'Your Loop', 'isNew': true},
//       {'name': 'mindcast', 'isNew': false},
//       {'name': 'vibeteller', 'isNew': false},
//       {'name': 'moodrealms', 'isNew': false},
//       {'name': 'inkdrop', 'isNew': false},
//     ];
//
//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: stories.length,
//         itemBuilder: (context, index) {
//           final story = stories[index];
//           return Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     /* Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: story['isNew'] == true
//                               ? [Colors.purple, Colors.pink]
//                               : [Colors.orange, Colors.pink],
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(2),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: AppColors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           // child: Padding(
//                           //   padding: const EdgeInsets.all(2),
//                           //   child: Container(
//                           //     decoration: const BoxDecoration(
//                           //       color: AppColors.premiumGold,
//                           //       shape: BoxShape.circle,
//                           //     ),
//                               child: CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor: AppColors.transparent,
//                                 backgroundImage: NetworkImage(
//                                   'https://images.pexels.com/photos/39317/baby-child-happy-joy-39317.jpeg',
//                                 ),
//                               ),
//                           //   ),
//                           // ),
//                         ),
//                       ),
//                     ),*/
//
//                     Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           colors: story['isNew'] == true
//                               ? [Colors.purple, Colors.pink]
//                               : [Colors.orange, Colors.pink],
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(3), // border thickness
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: AppColors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           child: ClipOval(
//                             child: Image.network(
//                               'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                               height: double.infinity,
//                               loadingBuilder: (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return const Center(child: CircularProgressIndicator());
//                               },
//                               errorBuilder: (_, __, ___) => const Icon(Icons.error),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     if (story['isNew'] == true)
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: AppColors.white, width: 2),
//                           ),
//                           child: const Icon(
//                             Icons.add,
//                             color: AppColors.white,
//                             size: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   story['name'] as String,
//                   style: const TextStyle(fontSize: 12,color: AppColors.white),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Post Widget
//   Widget _buildPost({
//     required String username,
//     required bool verified,
//     required String likes,
//     required String time,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Post Header
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [Colors.orange.shade400, Colors.pink.shade500],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           username,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: AppColors.white
//                           ),
//                         ),
//                         if (verified)
//                           const Padding(
//                             padding: EdgeInsets.only(left: 4),
//                             child: Icon(
//                               Icons.verified,
//                               color: Colors.blue,
//                               size: 16,
//                             ),
//                           ),
//                       ],
//                     ),
//                     const Text(
//                       '🎵 Imam Malboo • Neha Nair, Kinanu Kondu',
//                       style: TextStyle(fontSize: 11, color: AppColors.premiumGold),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.more_vert,color: AppColors.white,),
//             ],
//           ),
//         ),
//
//         // Post Image
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Stack(
//             children: [
//               Container(
//                 height: 400,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(24),
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.orange.shade300,
//                       Colors.orange.shade200,
//                       Colors.orange.shade100,
//                     ],
//                   ),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: Image.network(
//                     "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg",
//                     fit: BoxFit.cover,
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return const Center(child: CircularProgressIndicator());
//                     },
//                     errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 child: Row(
//                   children: [
//                     Row(
//                       children: [
//                         _buildLikeAvatar(Colors.red.shade400),
//                         Transform.translate(
//                           offset: const Offset(-8, 0),
//                           child: _buildLikeAvatar(Colors.blue.shade400),
//                         ),
//                         Transform.translate(
//                           offset: const Offset(-16, 0),
//                           child: _buildLikeAvatar(Colors.pink.shade400),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       '$likes Liked',
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.bold,
//                         shadows: [
//                           Shadow(
//                             offset: Offset(0, 1),
//                             blurRadius: 4,
//                             color: AppColors.white,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Action Buttons
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               const Icon(Icons.favorite, color: Colors.red, size: 28),
//               const SizedBox(width: 16),
//               const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
//               const SizedBox(width: 16),
//               const Icon(Icons.send,color: AppColors.white, size: 28),
//               const SizedBox(width: 16),
//               const Icon(Icons.more_horiz,color: AppColors.white, size: 28),
//             ],
//           ),
//         ),
//
//         // Post Info
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 time,
//                 style: const TextStyle(fontSize: 12, color: AppColors.premiumGold),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 '@vibeteller, @mooddreamlms and others liked this post!',
//                 style: TextStyle(fontSize: 12, color: AppColors.premiumGold),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 '@mindcast soft hues, slow days, and a heart full of stillness ☕ ...more',
//                 style: TextStyle(fontSize: 14,color: AppColors.white),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget _buildLikeAvatar(Color color) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//         border: Border.all(color: AppColors.white, width: 2),
//       ),
//     );
//   }
//
//   // Bottom Navigation
//   Widget _buildBottomNavigation(context) {
//     return Container(
//       height: 70,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(top: BorderSide(color: AppColors.premiumGold)),
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home, 'Home', true),
//               _buildNavItem(Icons.search, 'Search', false),
//               const SizedBox(width: 60),
//               _buildNavItem(Icons.repeat, 'Loops', false),
//               _buildNavItem(Icons.person_outline, 'Profile', false),
//             ],
//           ),
//           Positioned(
//             top: -20,
//             left: MediaQuery.of(context).size.width / 2 - 28,
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.white,
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.add_circle,
//                 color: AppColors.white,
//                 size: 32,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? Colors.blue : AppColors.premiumGold,
//           size: 24,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isActive ? Colors.blue : AppColors.premiumGold,
//             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// class PostCardWidget extends StatelessWidget {
//   final String username;
//   final String profileImage;
//   final String timeAgo;
//   final String postImage;
//   final String tagName;
//   final String caption;
//   final VoidCallback onMoreTap;
//
//   const PostCardWidget({
//     super.key,
//     required this.username,
//     required this.profileImage,
//     required this.timeAgo,
//     required this.postImage,
//     required this.tagName,
//     required this.caption,
//     required this.onMoreTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Container(
//         margin: const EdgeInsets.only(top: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// ----------- HEADER ---------------
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundImage: NetworkImage(profileImage),
//                   ),
//                   const SizedBox(width: 12),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               username,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.white,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: const Text(
//                                 'Follow',
//                                 style: TextStyle(
//                                   color: AppColors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 2),
//
//                         Text(
//                           timeAgo,
//                           style: const TextStyle(
//                             color: AppColors.premiumGold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   /// More Icon
//                   IconButton(
//                     icon: const Icon(Icons.more_vert),
//                     onPressed: onMoreTap,
//                   ),
//                 ],
//               ),
//             ),
//
//             /// ----------- IMAGE ---------------
//             ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Image.network(
//                 postImage,
//                 width: double.infinity,
//                 height: 200,
//                 fit: BoxFit.cover,
//               ),
//             ),
//
//             /// ----------- ACTIONS + CAPTION ---------------
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: const [
//                       Icon(Icons.favorite_border),
//                       SizedBox(width: 20),
//                       Icon(Icons.message),
//                       SizedBox(width: 20),
//                       Icon(Icons.share_sharp),
//                     ],
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   /// Tag Container
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF4FC3F7),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       tagName,
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   /// Caption
//                   Text(
//                     caption,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.white,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class CommentsBottomSheet extends StatefulWidget {
//   final int postId;
//   const CommentsBottomSheet({super.key, required this.postId});
//
//   @override
//   State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
// }
//
// class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
//   late final CommentController commentController;
//   BuildContext? bottomSheetContext;
//   final TextEditingController textController = TextEditingController();
//
//   int? replyingToCommentId;
//   String? replyingToUsername;
//
//   @override
//   void initState() {
//     super.initState();
//     commentController = Get.put(CommentController());
//     commentController.fetchComments(widget.postId);
//   }
//
//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.75,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, scrollController) {
//           return ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       AppColors.white.withOpacity(0.85),
//                       AppColors.white.withOpacity(0.55),
//                     ],
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(40),
//                     topRight: Radius.circular(40),
//                   ),
//                   border: Border.all(
//                     color: AppColors.white.withOpacity(0.3),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     /// --- HEADER ----
//                     _buildHeader(),
//
//                     Divider(height: 1, color: AppColors.premiumGold),
//
//                     /// --- COMMENT LIST ----
//                     Expanded(
//                       child: Obx(() {
//                         if (commentController.isLoading.value) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         if (commentController.commentsList.isEmpty) {
//                           return _buildEmptyState();
//                         }
//
//                         return ListView.builder(
//                           controller: scrollController,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           itemCount: commentController.commentsList.length,
//                           itemBuilder: (_, index) {
//                             final comment = commentController.commentsList[index];
//                             return _buildMainComment(comment, index, widget.postId);
//                           },
//                         );
//                       }),
//                     ),
//
//                     /// --- COMMENT INPUT FIELD ----
//                     _buildInputField(),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       child: Column(
//         children: [
//           // Drag handle
//           Container(
//             height: 4,
//             width: 40,
//             decoration: BoxDecoration(
//               color: AppColors.premiumGold,
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   Icons.chat_bubble_outline_rounded,
//                   color: Colors.blue.shade700,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Comments",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.white,
//                       ),
//                     ),
//                     Obx(() => Text(
//                       "${commentController.commentsList.length} ${commentController.commentsList.length == 1 ? 'comment' : 'comments'}",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: AppColors.premiumGold,
//                       ),
//                     )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.premiumGold,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.chat_bubble_outline_rounded,
//               size: 50,
//               color: AppColors.premiumGold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "No comments yet",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppColors.premiumGold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Be the first to share your thoughts!",
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.premiumGold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainComment(comment, int index, int postId) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       child: Column(
//         children: [
//           GestureDetector(
//             onLongPressStart: (details) {
//               if (comment.is_mine == true) {
//                 _showDeletePopupBlur(
//                   context,
//                   details.globalPosition,
//                   comment.id,
//                   index,
//                   postId,
//                   isReply: false,
//                 );
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               color: AppColors.transparent,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar with online indicator
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundColor: AppColors.premiumGold,
//                         backgroundImage: (comment.user?.avtar != null &&
//                             comment.user?.avtar != "")
//                             ? NetworkImage(comment.user!.avtar!)
//                             : null,
//                         child: (comment.user?.avtar == null ||
//                             comment.user?.avtar == "")
//                             ? Icon(
//                           Icons.person,
//                           color: AppColors.premiumGold,
//                           size: 24,
//                         )
//                             : null,
//                       ),
//                       if (comment.is_mine == true)
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             width: 12,
//                             height: 12,
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: AppColors.white, width: 2),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Comment content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Username and time
//                         Row(
//                           children: [
//                             Text(
//                               comment.user?.username ?? "Unknown",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//
//                         // Comment text
//                         Text(
//                           comment.body ?? "",
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: AppColors.white,
//                             height: 1.4,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//
//                         // Action buttons
//                         Row(
//                           children: [
//                             _buildActionButton(
//                               icon: comment.hasLiked
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               label: "${comment.likesCount}",
//                               color: comment.hasLiked ? Colors.red : AppColors.premiumGold,
//                               onTap: () {
//                                 commentController.likeComment(comment.id, index);
//                               },
//                             ),
//                             const SizedBox(width: 20),
//                             _buildActionButton(
//                               icon: Icons.reply_rounded,
//                               label: "Reply",
//                               color: AppColors.premiumGold,
//                               onTap: () {
//                                 setState(() {
//                                   replyingToCommentId = comment.id;
//                                   replyingToUsername = comment.user?.username;
//                                 });
//                                 FocusScope.of(context).requestFocus(FocusNode());
//                               },
//                             ),
//                             if (comment.replies.isNotEmpty) ...[
//                               const SizedBox(width: 20),
//                               Text(
//                                 "${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: AppColors.premiumGold,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Replies with indentation (no border line)
//           if (comment.replies.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.only(left: 48),
//               child: Column(
//                 children: comment.replies.asMap().entries.map<Widget>((entry) {
//                   int replyIndex = entry.key;
//                   var reply = entry.value;
//                   return _buildReply(reply, index, replyIndex, widget.postId);
//                 }).toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReply(reply, int commentIndex, int replyIndex, int postId) {
//     return GestureDetector(
//       onLongPressStart: (details) {
//         if (reply.is_mine == true) {
//           _showDeletePopupBlur(
//             context,
//             details.globalPosition,
//             reply.id,
//             commentIndex,
//             postId,
//             isReply: true,
//             replyIndex: replyIndex,
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: AppColors.premiumGold,
//               backgroundImage: (reply.user?.avtar != null &&
//                   reply.user?.avtar != "")
//                   ? NetworkImage(reply.user!.avtar!)
//                   : null,
//               child: (reply.user?.avtar == null ||
//                   reply.user?.avtar == "")
//                   ? Icon(
//                 Icons.person,
//                 color: AppColors.premiumGold,
//                 size: 20,
//               )
//                   : null,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         reply.user?.username ?? "Unknown",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     reply.body ?? "",
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.white,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               color: color,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputField() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//       decoration: BoxDecoration(
//         color: AppColors.black.withOpacity(1.0),
//         border: Border(
//           top: BorderSide(color: AppColors.premiumGold, width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.premiumGold.withOpacity(0.05),
//             offset: const Offset(0, -2),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Replying indicator
//           if (replyingToCommentId != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               margin: const EdgeInsets.only(bottom: 12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.blue.shade50,
//                     Colors.blue.shade100.withOpacity(0.3),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue.shade200, width: 1),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.reply_rounded,
//                     size: 16,
//                     color: Colors.blue.shade700,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       "Replying to @$replyingToUsername",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.blue.shade900,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         replyingToCommentId = null;
//                         replyingToUsername = null;
//                       });
//                     },
//                     child: Icon(
//                       Icons.close_rounded,
//                       size: 18,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           // Input field
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.premiumGold,
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: AppColors.premiumGold, width: 1),
//                   ),
//                   child: TextField(
//                     controller: textController,
//                     maxLines: null,
//                     style: const TextStyle(fontSize: 14, color: AppColors.white),
//                     decoration: InputDecoration(
//                       hintText: replyingToCommentId != null
//                           ? "Write a reply..."
//                           : "Share your thoughts...",
//                       hintStyle: TextStyle(
//                         color: AppColors.premiumGold,
//                         fontSize: 14,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               GestureDetector(
//                 onTap: () async {
//                   final text = textController.text.trim();
//                   if (text.isNotEmpty) {
//                     if (replyingToCommentId != null) {
//                       await commentController.createReplyComment(
//                         commentId: replyingToCommentId!,
//                         body: text,
//                         postId: widget.postId,
//                       );
//                     } else {
//                       await commentController.createComment(
//                         postId: widget.postId,
//                         body: text,
//                       );
//                       Navigator.pop(context, commentController.commentsList.length);
//                     }
//
//                     textController.clear();
//                     setState(() {
//                       replyingToCommentId = null;
//                       replyingToUsername = null;
//                     });
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.blue.shade600, Colors.blue.shade700],
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade300,
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.send_rounded,
//                     color: AppColors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeletePopupBlur(
//       BuildContext context,
//       Offset position,
//       int commentId,
//       int commentIndex,
//       int postId, {
//         required bool isReply,
//         int? replyIndex,
//       }) {
//     OverlayState overlayState = Overlay.of(context);
//     late OverlayEntry blurEntry;
//     late OverlayEntry popupEntry;
//
//     blurEntry = OverlayEntry(
//       builder: (_) => GestureDetector(
//         onTap: () {
//           blurEntry.remove();
//           popupEntry.remove();
//         },
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(color: AppColors.white.withOpacity(0.4)),
//         ),
//       ),
//     );
//
//     popupEntry = OverlayEntry(
//       builder: (context) {
//         return Positioned(
//           left: position.dx - 80,
//           top: position.dy - 10,
//           child: Material(
//             color: AppColors.transparent,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.red.shade400, Colors.red.shade600],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     blurRadius: 15,
//                     color: Colors.red.withOpacity(0.4),
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: GestureDetector(
//                 onTap: () async {
//                   blurEntry.remove();
//                   popupEntry.remove();
//
//                   if (isReply && replyIndex != null) {
//                     // Delete reply
//                     Navigator.pop(context);
//                     await commentController.deleteComments(postId, commentId);
//                     commentController.commentsList[commentIndex].replies.removeAt(replyIndex);
//
//                   } else {
//                     // Delete main comment
//                     await commentController.deleteComments(postId, commentId);
//                     commentController.commentsList.removeAt(commentIndex);
//                   }
//
//                   if (!isReply) {
//                     Navigator.pop(bottomSheetContext!);
//                   }
//                 },
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Icon(Icons.delete_rounded, color: AppColors.white, size: 20),
//                     SizedBox(width: 8),
//                     Text(
//                       "Delete",
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//
//     overlayState.insert(blurEntry);
//     overlayState.insert(popupEntry);
//   }
// }
//
// popupEntry
// class PostMediaWidget extends StatefulWidget {
//   final PostItem post;
//   final int index;
//   final HomeController controller;
//
//   const PostMediaWidget({
//     super.key,
//     required this.post,
//     required this.index,
//     required this.controller,
//   });
//
//   @override
//   State<PostMediaWidget> createState() => _PostMediaWidgetState();
// }
//
// class _PostMediaWidgetState extends State<PostMediaWidget>
//     with SingleTickerProviderStateMixin {
//   bool showHeart = false;
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//
//     _scaleAnimation =
//         Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(
//           parent: _animationController,
//           curve: Curves.easeOutBack,
//         ));
//
//     _animationController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         Future.delayed(const Duration(milliseconds: 300), () {
//           _animationController.reverse();
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void handleDoubleTap() {
//     widget.controller.likePost(widget.post.id, widget.index);
//
//     setState(() {
//       showHeart = true;
//     });
//
//     _animationController.forward(from: 0);
//     Future.delayed(const Duration(milliseconds: 700), () {
//       setState(() {
//         showHeart = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaUrl = widget.post.media.isNotEmpty ? widget.post.media.first.url : "";
//
//     return GestureDetector(
//       onDoubleTap: handleDoubleTap,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.network(
//               mediaUrl,
//               height: 250,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stack) {
//                 return Image.asset(
//                   AppAssets.imgOnbording3,
//                   height: 250,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 );
//               },
//             ),
//           ),
//
//           // Video icon
//           if (widget.post.type == "video")
//             Positioned(
//               top: 10,
//               right: 10,
//               child: Icon(
//                 Icons.videocam_rounded,
//                 color: AppColors.white,
//                 size: 28,
//               ),
//             ),
//
//           // Heart Animation
//           if (showHeart)
//             ScaleTransition(
//               scale: _scaleAnimation,
//               child: Icon(
//                 Icons.favorite,
//                 color: AppColors.black.withOpacity(1.0),
//                 size: 100,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//

class AnimatedProBadge extends StatefulWidget {
  const AnimatedProBadge({Key? key}) : super(key: key);

  @override
  State<AnimatedProBadge> createState() => _AnimatedProBadgeState();
}

class _AnimatedProBadgeState extends State<AnimatedProBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () async {
              final homeController = Get.find<HomeController>();
              var config = homeController.profileConfig.value;

              if (config == null) {
                // Try reading from SharedPreferences
                final cached = SharedPrefManager().profileConfig;
                if (cached != null) {
                  try {
                    config = ProfileConfigModel.fromJson(cached);
                  } catch (e) {
                    debugPrint("Error reading cached config: $e");
                  }
                }
              }

              if (config == null) {
                // Show loading spinner
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                  barrierDismissible: false,
                );

                try {
                  await homeController.fetchProfileConfig();
                  config = homeController.profileConfig.value;
                } catch (e) {
                  debugPrint("Error fetching profile config: $e");
                }

                Get.back(); // close loading dialog
              }

              if (config == null) {
                Get.snackbar(
                  "Error",
                  "Failed to retrieve profile configuration. Please check your internet connection.",
                  backgroundColor: Colors.red,
                  colorText: AppColors.white,
                );
                return;
              }

              // Resolve current active profile from config
              final currentProfileName =
                  config.data?.userProfile?.currentProfileName;
              if (currentProfileName == null || currentProfileName.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Current active profile name is not set.",
                  backgroundColor: Colors.red,
                  colorText: AppColors.white,
                );
                return;
              }

              String mappedProfileType = 'personal';
              int? profileId;
              String? activePlanSlug;
              bool isSubscribedActive = false;
              dynamic profileObj;

              if (currentProfileName == 'personal' ||
                  currentProfileName == 'personal_profile') {
                mappedProfileType = 'personal';
                profileObj = config.data?.personalProfile;
                profileId = profileObj?.profileId;
                activePlanSlug = profileObj?.subscription?.planSlug;
                isSubscribedActive =
                    profileObj?.subscription?.isActive ?? false;
              } else if (currentProfileName == 'employer') {
                mappedProfileType = 'employer';
                profileObj = config.data?.employer;
                profileId = profileObj?.profileId;
                activePlanSlug = profileObj?.subscription?.planSlug;
                isSubscribedActive =
                    profileObj?.subscription?.isActive ?? false;
              } else if (currentProfileName == 'ecommerce' ||
                  currentProfileName == 'seller') {
                mappedProfileType = 'seller';
                profileObj = config.data?.ecommerce;
                profileId = profileObj?.profileId;
                activePlanSlug = profileObj?.subscription?.planSlug;
                isSubscribedActive =
                    profileObj?.subscription?.isActive ?? false;
              } else if (currentProfileName == 'music_play' ||
                  currentProfileName == 'music') {
                mappedProfileType = 'music';
                profileObj = config.data?.musicPlay;
                profileId = profileObj?.profileId;
                activePlanSlug = profileObj?.subscription?.planSlug;
                isSubscribedActive =
                    profileObj?.subscription?.isActive ?? false;
              } else if (currentProfileName == 'content_creation' ||
                  currentProfileName == 'creator') {
                mappedProfileType = 'creator';
                profileObj = config.data?.contentCreation;
                profileId = profileObj?.profileId;
                activePlanSlug = profileObj?.subscriptionDetails?.planSlug;
                isSubscribedActive =
                    profileObj?.subscriptionDetails?.isActive ?? false;
              }

              if (profileObj == null) {
                Get.snackbar(
                  "Error",
                  "Profile configuration details are missing for: $currentProfileName",
                  backgroundColor: Colors.red,
                  colorText: AppColors.white,
                );
                return;
              }

              try {
                final subscriptionController =
                    Get.isRegistered<SubscriptionController>()
                        ? Get.find<SubscriptionController>()
                        : Get.put(SubscriptionController());

                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                  barrierDismissible: false,
                );

                final resolvedSub = await subscriptionController
                    .fetchPlansForProfileType(
                      mappedProfileType,
                      activePlanSlug: activePlanSlug,
                      isSubscribedActive: isSubscribedActive,
                      profileId: profileId,
                    );

                Get.back(); // Close loading dialog

                if (resolvedSub != null) {
                  Get.to(() => ProfilePlansScreen(profileTypeSub: resolvedSub));
                } else {
                  Get.snackbar(
                    "Error",
                    "Failed to load plans for profile type: $mappedProfileType",
                    backgroundColor: Colors.red,
                    colorText: AppColors.white,
                  );
                }
              } catch (e) {
                Get.back(); // Close loading dialog in case of error
                Get.snackbar(
                  "Error",
                  "Something went wrong while loading plans: $e",
                  backgroundColor: Colors.red,
                  colorText: AppColors.white,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.premiumGold,
                    AppColors.goldHighlight,
                    AppColors.goldGlow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: const Color(0xFFFFF7C2), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    "PRO",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      shadows: [
                        Shadow(
                          color: AppColors.white,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSubscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFD4AF37),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Upgrade to IVatan PRO",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Unlock all premium features, badges, and services.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.premiumGold, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildFeatureRow(
                Icons.check_circle_rounded,
                "Golden Verified Profile Badge",
              ),
              _buildFeatureRow(
                Icons.check_circle_rounded,
                "Priority Support & Approval",
              ),
              _buildFeatureRow(
                Icons.check_circle_rounded,
                "Unlimited Product & Service Listings",
              ),
              _buildFeatureRow(
                Icons.check_circle_rounded,
                "Access to Exclusive Music Playlists",
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF099),
                      Color(0xFFD4AF37),
                      Color(0xFF9F7A1A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      "Premium",
                      "Subscription processing is coming soon!",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.transparent,
                      colorText: AppColors.white,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.transparent,
                    shadowColor: AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    "Subscribe Now - 9.99/mo",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
