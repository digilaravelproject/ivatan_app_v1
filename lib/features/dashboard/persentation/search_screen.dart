import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/helper/custom_image_view.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/features/search/controller/mixed_feed_controller.dart';
import '../../../core/helper/custom_serchbar.dart';
import '../../../core/helper/my_image_slider.dart';
import '../../post/presentation/image_post_screen.dart';
import '../../videos/persentation/play_video_screen.dart';
import 'comming_soon.dart';
import '../../../core/network/app_urls.dart';
import '../../search/model/mixed_feed_model.dart';
import '../../reels_screen/model/reel_model.dart' as rm;
import '../../reels_screen/persentation/reels_view.dart';
import 'user_search_screen.dart';
import '../../dashboard/model/post_model.dart' as pm;
import '../../profile/screen/profile_feed_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.put(PostController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.imgBackgroundApp),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 1. Search Bar
                SliverToBoxAdapter(
                  child: CustomSearchBar(
                    readOnly: true,
                    onTap: () => Get.to(() => UserSearchScreen()),
                  ),
                ),

                // 2. Banner Slider
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.bannersList.isEmpty) {
                      if (controller.isLoading.value) {
                        return const SizedBox(
                          height: 130,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 130,
                          child: ImageSlider(
                            images: controller.bannersList
                                .map((banner) => banner.mediaUrl)
                                .toList(),
                            viewPort: 0.9,
                            borderRadius: 16,
                            autoScroll: true,
                            isIndicatorVisible: true,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 8),
                            indicatorAlignment: MainAxisAlignment.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }),
                ),

                // 3. Pinned TabBar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      indicatorColor: AppColors.premiumGold,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppColors.premiumGold,
                      unselectedLabelColor: AppColors.lightTextSecondary,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: "Trending"),
                        Tab(text: "Live"),
                        Tab(text: "For You"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                TrendingScreen(),
                CustomEmptyState(
                  title: "Live Coming Soon",
                  subTitle: "We are getting the stage ready for you!",
                  icon: Icons.live_tv_rounded,
                ),
                ForYouGridScreen(),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent, // Let background image show through
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class TrendingScreen extends StatelessWidget {
  TrendingScreen({Key? key}) : super(key: key);

  final PostController controller = Get.put(PostController());


  @override
  Widget build(BuildContext context) {
    List<String> sliderImages = [
      "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
      "https://images.pexels.com/photos/34950/pexels-photo.jpg",
      "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg",
      "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
      "https://images.pexels.com/photos/34950/pexels-photo.jpg",
      "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg",
    ];
    return RefreshIndicator(
      onRefresh: () => controller.refreshAll(),
      color: Colors.black,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // Interested posts horizontal list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 130,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildStoryShimmer();
                  }
                  if (controller.intrestedPostList.isEmpty) {
                    return Center(
                      child: CustomEmptyState(
                        title: "No Trending",
                        subTitle: "",
                        icon: Icons.trending_up,
                        isSmall: true,
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: controller.intrestedPostList.length,
                    itemBuilder: (context, index) {
                      final story = controller.intrestedPostList[index];
                      return _buildStoryItem(
                          story.media.first.thumbnail,
                          story.stats.viewCount.toString(),
                          story.media.first.type,
                          story.media.first.url,
                          story.id
                      );
                    },
                  );
                }),
              ),
            ),
          ),

          // Spacing between stories and grid
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Masonry grid
          SliverPadding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 90),
            sliver: Obx(() {
              if (controller.isLoading.value) {
                return SliverToBoxAdapter(
                  child: _buildGridShimmer(),
                );
              }
              if (controller.posts.isEmpty) {
                return SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: CustomEmptyState(
                      title: "No Posts Yet",
                      subTitle: "Be the first to create something amazing!",
                      icon: Icons.post_add_rounded,
                    ),
                  ),
                );
              }
              return SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final item = controller.posts[index];
                  final String thumb = (item.media.isNotEmpty)
                      ? (item.media.first.thumbnail.isNotEmpty
                      ? item.media.first.thumbnail
                      : item.media.first.url)
                      : "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg";

                  return GestureDetector(
                    onTap: () {
                      if (item.type == "video") {
                        Get.to(() => VideoPlayerScreen(videoUrl: item.media.first.url, videoId: item.id));
                      } else if (item.type == "reel") {
                        final List<rm.ReelModel> reelList = controller.posts
                            .where((p) => p.type == "reel" && p.media.isNotEmpty)
                            .map((p) => _convertToReelModel(p))
                            .toList();
                        final int initialIndex = reelList.indexWhere((r) => r.id == item.id);
                        if (reelList.isNotEmpty) {
                          Get.to(() => ReelsView(
                            reels: reelList,
                            initialIndex: initialIndex >= 0 ? initialIndex : 0,
                          ));
                        }
                      } else {
                        final List<pm.PostItem> postItemList = controller.posts
                            .where((p) => p.type != "video" && p.type != "reel")
                            .map((p) => _convertToPostItem(p))
                            .toList();
                        final int initialIndexImage = postItemList.indexWhere((p) => p.id == item.id);
                        if (postItemList.isNotEmpty) {
                          Get.to(() => ProfileFeedScreen(
                            posts: postItemList,
                            initialIndex: initialIndexImage >= 0 ? initialIndexImage : 0,
                          ));
                        }
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: (index % 2 == 0) ? 220 : 150,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: AppUrls.getFullImageUrl(thumb),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.grey.shade300),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Image.asset(AppAssets.imgAppLogo, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          // Type indicator
                          if (item.type == "video" || item.type == "reel")
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.type == "reel" ? Icons.slow_motion_video : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      item.stats.viewCount > 0 ? '${item.stats.viewCount}' : '',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );

  }
  Widget _buildStoryItem(String thumbnailUrl,
      String viewsCount,String postType,String videoUrl,int postId) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () {
                if (postType == "video") {
                  Get.to(() => VideoPlayerScreen(videoUrl: videoUrl, videoId: postId, ));
                }
                else if (postType == "reel") {
                  // Find the post in controller and open as reel
                  final post = controller.intrestedPostList.firstWhereOrNull((p) => p.id == postId);
                  if (post != null) {
                    final List<rm.ReelModel> reelList = controller.intrestedPostList
                        .where((p) => p.type == "reel" && p.media.isNotEmpty)
                        .map((p) => _convertToReelModel(p))
                        .toList();

                    final int initialIndex = reelList.indexWhere((r) => r.id == postId);
                    if (reelList.isNotEmpty) {
                      Get.to(() => ReelsView(
                        reels: reelList,
                        initialIndex: initialIndex >= 0 ? initialIndex : 0,
                      ));
                    }
                  }
                }
                else {
                  final List<pm.PostItem> postItemList = controller.intrestedPostList
                      .where((p) => p.type != "video" && p.type != "reel")
                      .map((p) => _convertToPostItem(p))
                      .toList();
                  final int initialIndex = postItemList.indexWhere((p) => p.id == postId);
                  if (postItemList.isNotEmpty) {
                    Get.to(() => ProfileFeedScreen(
                      posts: postItemList,
                      initialIndex: initialIndex >= 0 ? initialIndex : 0,
                    ));
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 130,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Image.asset(AppAssets.imgAppLogo, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      viewsCount,
                      style: TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildStoryShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 100,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridShimmer() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(6, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: (MediaQuery.of(Get.context!).size.width - 36) / 2,
            height: (index % 2 == 0) ? 220 : 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  rm.ReelModel _convertToReelModel(TrendingPost post) {
    return rm.ReelModel(
      id: post.id,
      uuid: post.uuid,
      caption: post.caption ?? "",
      isMine: post.isMine,
      isFollowing: post.isFollowing,
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
      createdAt: post.createdAt.toIso8601String(),
      createdHuman: post.createdHuman,
      likeStatus: post.stats.isLiked,
    );
  }

  pm.PostItem _convertToPostItem(TrendingPost post) {
    return pm.PostItem(
      id: post.id,
      uuid: post.uuid,
      type: post.type,
      caption: post.caption ?? "",
      visibility: "public",
      is_mine: post.isMine,
      is_following: post.isFollowing,
      user: pm.PostUser(
        id: post.user.id,
        name: post.user.name,
        username: post.user.username,
        avatar: post.user.avatar ?? "",
        isVerified: post.user.isVerified,
        occupation: "",
        interests: post.user.interests ?? "",
      ),
      media: post.media.map((m) => pm.PostMedia(
        id: m.id,
        type: m.type,
        url: m.url,
        thumbnail: m.thumbnail,
        mimeType: m.mimeType,
        aspectRatio: "",
      )).toList(),
      stats: pm.PostStats(
        likeCount: post.stats.likeCount,
        commentCount: post.stats.commentCount,
        shareCount: post.stats.shareCount,
        viewCount: post.stats.viewCount,
        isLiked: post.stats.isLiked,
        isSaved: post.stats.isSaved,
        isBlocked: false,
      ),
      createdAt: post.createdAt.toIso8601String(),
      createdHuman: post.createdHuman,
      isPurchased: false,
      price: null,
      hasAccess: false,
      isExclusive: false,
    );
  }
}

class LiveScreen extends StatelessWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<String> sliderImages = [
      "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
      "https://images.pexels.com/photos/34950/pexels-photo.jpg",
      "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg",
      "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
      "https://images.pexels.com/photos/34950/pexels-photo.jpg",
      "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg",
    ];

    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Column(
        children: [
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildStoryItem('https://images.pexels.com/photos/34950/pexels-photo.jpg',context);
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: MasonryGridView.count(
                crossAxisCount: 2,     // 2 columns
                mainAxisSpacing: 12,   // vertical spacing
                crossAxisSpacing: 12,  // horizontal spacing
                itemCount: sliderImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        image: DecorationImage(
                          image: NetworkImage(sliderImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: (index % 2 == 0) ? 220 : 150, // DIFFERENT HEIGHTS
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
      GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return VideoCard(
          imageUrl: 'https://picsum.photos/400/500?random=${index + 20}',
          views: '${(index + 1) * 100}K',
          isLive: true,
          creator: 'User ${index + 1}',
        );
      },
    );

  }

  Widget _buildStoryItem(String imageUrl, BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double avatarRadius = w * 0.11;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Container(
            margin: EdgeInsets.only(top: avatarRadius - 3),
            width: 150,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 35),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Harsh Patel",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                     // SizedBox(height: 2),
                      Text(
                        "@harsh",
                        style: TextStyle(
                          color: AppColors.black.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Top circular avatar (large)
          Positioned(
            top: -5,
            left: (150 / 2) - avatarRadius, // Center horizontally
            child: CircleAvatar(
              radius: avatarRadius,
             // backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: avatarRadius - 3,
                backgroundImage: NetworkImage(AppUrls.getFullImageUrl(imageUrl)),
              ),
            ),
          ),

          // LIVE badge (top right)
          Positioned(
            top: avatarRadius + 10,
            right: 3,
            child: CustomImageView(
              imagePath: AppAssets.imgLive,
              height: 30,
              width: 30,
            ),
          ),
        ],
      ),
    );
  }


}

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return _buildStoryItem('https://images.pexels.com/photos/34950/pexels-photo.jpg');
                  },
                ),
              ),
            ],
          ),
        ),
      );
      /*GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return VideoCard(
          imageUrl: 'https://picsum.photos/400/500?random=${index + 40}',
          views: '${(index + 1) * 50}K',
          isLive: index % 4 == 0,
          creator: 'Creator ${index + 1}',
        );
      },
    );*/
  }

  Widget _buildStoryItem(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 270,
            height: 120,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 6,
           // left: -1,
            right: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "1.2K",
                      style: TextStyle(color: Colors.white, fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
             left: 6,
            right: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                    ),
                    SizedBox(width: 5,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        // border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 5),
                        child: Column(
                          children: [
                            Text("Harsh Patel",style: TextStyle(color: AppColors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                            Text("@harshpatel",style: TextStyle(color: AppColors.white,fontSize: 12,),),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

}

class VideoCard extends StatelessWidget {
  final String imageUrl;
  final String views;
  final bool isLive;
  final String creator;

  const VideoCard({
    Key? key,
    required this.imageUrl,
    required this.views,
    required this.isLive,
    required this.creator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.play_circle_outline,
                size: 60,
                color: Colors.white70,
              ),
            ),

            // Live Badge
            if (isLive)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Views Count
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      views,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bookmark Icon
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*class ForYouScreen extends StatelessWidget {
  ForYouScreen({super.key});

  final List<Map<String, String>> reels = [
    {
      "image": "assets/r1.jpg",
      "name": "Harsh Patal",
      "username": "@harsh.o5.HA124",
      "views": "1.2M",
    },
    {
      "image": "assets/r2.jpg",
      "name": "Harsh Patal",
      "username": "@harsh.o5.HA124",
      "views": "1.2M",
    },
    {
      "image": "assets/r3.jpg",
      "name": "Harsh Patal",
      "username": "@harsh.o5.HA124",
      "views": "1.2M",
    },
    {
      "image": "assets/r4.jpg",
      "name": "Harsh Patal",
      "username": "@harsh.o5.HA124",
      "views": "1.2M",
    },
  ];

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ------------------ TOP FULL WIDTH CARD ------------------
            buildTopBigReel(w, reels[0]),

            const SizedBox(height: 6),

            // ------------------ GRID 2 COLUMNS ------------------
            GridView.builder(
              itemCount: reels.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(6),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                mainAxisExtent: w * 0.75, // equal layout like screenshot
              ),
              itemBuilder: (context, index) {
                return buildReelItem(reels[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== TOP FULL CARD ==========================
  Widget buildTopBigReel(double w, Map<String, String> data) {
    return Container(
      height: w * 0.63,
      width: w,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: AssetImage(data["image"]!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                const SizedBox(width: 4),
                Text(
                  data["views"]!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          Positioned(
            left: 12,
            bottom: 12,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage("assets/user.jpg"),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["name"]!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      Text(
                        data["username"]!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== GRID ITEM CARD ==========================
  Widget buildReelItem(Map<String, String> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: AssetImage(data["image"]!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Views top right
          Positioned(
            right: 10,
            top: 10,
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                const SizedBox(width: 4),
                Text(
                  data["views"]!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          // Bottom gradient + user
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14)),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage("assets/user.jpg"),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["name"]!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      Text(
                        data["username"]!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}*/

class ForYouGridScreen extends StatelessWidget {
  ForYouGridScreen({Key? key}) : super(key: key);

  final PostController controller = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchForYou(),
      color: Colors.black,
      child: Obx(() {
        if (controller.isLoading.value && controller.forYouPosts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(6, (index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 36) / 2,
                    height: (index % 2 == 0) ? 220 : 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          );
        }
        if (controller.forYouPosts.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              CustomEmptyState(
                title: "No Personalized Content",
                subTitle: "Pull down to refresh!",
                icon: Icons.favorite_rounded,
              ),
            ],
          );
        }
        return MasonryGridView.count(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 90),
          itemCount: controller.forYouPosts.length,
          itemBuilder: (context, index) {
            final item = controller.forYouPosts[index];
            final String thumb = (item.media.isNotEmpty)
                ? (item.media.first.thumbnail.isNotEmpty
                    ? item.media.first.thumbnail
                    : item.media.first.url)
                : "";

            return GestureDetector(
              onTap: () {
                if (item.type == "video") {
                  Get.to(() => VideoPlayerScreen(videoUrl: item.media.first.url, videoId: item.id));
                } else if (item.type == "reel") {
                  final List<rm.ReelModel> reelList = controller.forYouPosts
                      .where((p) => p.type == "reel" && p.media.isNotEmpty)
                      .map((p) => _convertToReelModel(p))
                      .toList();
                  final int initialIndex = reelList.indexWhere((r) => r.id == item.id);
                  if (reelList.isNotEmpty) {
                    Get.to(() => ReelsView(
                      reels: reelList,
                      initialIndex: initialIndex >= 0 ? initialIndex : 0,
                    ));
                  }
                } else {
                  final List<pm.PostItem> postItemList = controller.forYouPosts
                      .where((p) => p.type != "video" && p.type != "reel")
                      .map((p) => _convertToPostItem(p))
                      .toList();
                  final int initialIndex = postItemList.indexWhere((p) => p.id == item.id);
                  if (postItemList.isNotEmpty) {
                    Get.to(() => ProfileFeedScreen(
                      posts: postItemList,
                      initialIndex: initialIndex >= 0 ? initialIndex : 0,
                    ));
                  }
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    SizedBox(
                      height: (index % 2 == 0) ? 220 : 150,
                      width: double.infinity,
                      child: thumb.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: AppUrls.getFullImageUrl(thumb),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.grey.shade300),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Image.asset(AppAssets.imgAppLogo, fit: BoxFit.contain),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: Image.asset(AppAssets.imgAppLogo, fit: BoxFit.contain),
                            ),
                    ),
                    if (item.type == "video" || item.type == "reel")
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.type == "reel" ? Icons.slow_motion_video : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.stats.viewCount > 0 ? '${item.stats.viewCount}' : '',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  rm.ReelModel _convertToReelModel(TrendingPost post) {
    return rm.ReelModel(
      id: post.id,
      uuid: post.uuid,
      caption: post.caption ?? "",
      isMine: post.isMine,
      isFollowing: post.isFollowing,
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
      createdAt: post.createdAt.toIso8601String(),
      createdHuman: post.createdHuman,
      likeStatus: post.stats.isLiked,
    );
  }

  pm.PostItem _convertToPostItem(TrendingPost post) {
    return pm.PostItem(
      id: post.id,
      uuid: post.uuid,
      type: post.type,
      caption: post.caption ?? "",
      visibility: "public",
      is_mine: post.isMine,
      is_following: post.isFollowing,
      user: pm.PostUser(
        id: post.user.id,
        name: post.user.name,
        username: post.user.username,
        avatar: post.user.avatar ?? "",
        isVerified: post.user.isVerified,
        occupation: "",
        interests: post.user.interests ?? "",
      ),
      media: post.media.map((m) => pm.PostMedia(
        id: m.id,
        type: m.type,
        url: m.url,
        thumbnail: m.thumbnail,
        mimeType: m.mimeType,
        aspectRatio: "",
      )).toList(),
      stats: pm.PostStats(
        likeCount: post.stats.likeCount,
        commentCount: post.stats.commentCount,
        shareCount: post.stats.shareCount,
        viewCount: post.stats.viewCount,
        isLiked: post.stats.isLiked,
        isSaved: post.stats.isSaved,
        isBlocked: false,
      ),
      createdAt: post.createdAt.toIso8601String(),
      createdHuman: post.createdHuman,
      isPurchased: false,
      price: null,
      hasAccess: false,
      isExclusive: false,
    );
  }
}

