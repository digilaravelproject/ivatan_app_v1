import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/history_controller.dart';
import '../../model/history_model.dart';
import '../../../dashboard/persentation/widgets/feed_video_player.dart';
import '../../../videos/persentation/play_video_screen.dart';

/*
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leadingWidth: 40, // 👈 default padding kam karega
            titleSpacing: 0,
            backgroundColor: AppColors.transparent,
            leading: GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.black,
              ),
            ),
            title: Text(
              "History",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {},
                child: Text(
                  "Clear",
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SingleChildScrollView(
              child:Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          color: AppColors.lightTextSecondary,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Long Video",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Watch history",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "See All",
                        style: TextStyle(
                          color: AppColors.primary, 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "10:45",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "The Best Nature Scenes in 4K Ultra HD",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "12.3K views • 2 days ago",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.tune_rounded, color: Colors.grey.shade400, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                  width: 120,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Top 10 Cities to Visit in 2024",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Travel Guide • 45K views",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 18),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
*/





/*class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Clear",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      /// 🔥 BODY WITH STICKY TABS
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [

              /// 🔎 SEARCH BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.search,
                            color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

             // const SizedBox(height: 16),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "10:45",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "The Best Nature Scenes in 4K Ultra HD",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "12.3K views • 2 days ago",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// 🔥 STICKY TAB BAR
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                bottom: const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: "Likes"),
                    Tab(text: "Comments"),
                    Tab(text: "Shares"),
                  ],
                ),
              ),
            ];
          },

          /// 🔥 TAB CONTENT
          body: const TabBarView(
            children: [
              VideoGridSection(),
              VideoGridSection(),
              VideoGridSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoGridSection extends StatelessWidget {
  const VideoGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🎥 THUMBNAIL
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.network(
                        "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// ▶ VIDEO ICON
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 📄 TITLE
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Amazing Nature Video",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              /// ❤️ LIKE / COMMENT / SHARE
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconWithText(Icons.favorite_border, "1.2K"),
                    _iconWithText(Icons.comment_outlined, "340"),
                    _iconWithText(Icons.share_outlined, "120"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconWithText(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}*/






/// Enum for Video type
enum VideoType { like, comment, product, service }

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});
  
  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      /// BODY WITH STICKY TABS
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [

              /// SEARCH BAR
             /* SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(CupertinoIcons.search,
                            color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/

             /* SliverToBoxAdapter(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Long Videos",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 22),),
                    )
                  ],
                ),),*/

              /// HORIZONTAL VIDEO LIST


              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220, // Slider height adjust karo
                  child: Obx(() {
                    if (controller.isLoadingVideoViews.value && controller.videoViews.isEmpty) {
                      return _buildShimmerSlider();
                    }
                    if (controller.videoViews.isEmpty) {
                      return _buildEmptyState("No video history available");
                    }
                    
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!controller.isLoadingVideoViews.value &&
                            controller.hasMoreVideoViews &&
                            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                          controller.fetchVideoViews(loadMore: true);
                        }
                        return false;
                      },
                      child: PageView.builder(
                        itemCount: controller.videoViews.length,
                        controller: PageController(viewportFraction: 0.9),
                        padEnds: false,
                        itemBuilder: (context, index) {
                          final item = controller.videoViews[index];
                          final preview = item.preview;
                          final imageUrl = preview?.thumbnail ?? "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp";
                          
                          return GestureDetector(
                            onTap: () {
                              if (imageUrl.toLowerCase().contains('.mp4')) {
                                Get.to(() => VideoPlayerScreen(videoUrl: imageUrl, videoId: item.entityId));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  /// 🌄 IMAGE/VIDEO
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: imageUrl.toLowerCase().contains('.mp4')
                                        ? FeedVideoPlayer(videoUrl: imageUrl)
                                        : Image.network(
                                            imageUrl,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
                                          ),
                                  ),

                                /// 🌑 GRADIENT OVERLAY
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.black.withOpacity(0.0),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),

                                /// 🕒 TIME LABEL (Placeholder, can be updated later if API provides duration)
                                Positioned(
                                  bottom: 10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "Video",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                /// 📝 TITLE & VIEWS
                                Positioned(
                                  bottom: 12,
                                  left: 16,
                                  right: 80, // thoda space for time
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        preview?.caption ?? "Nature Video",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.createdHuman,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      ),
                    );
                  }),
                ),
              ),


              /*SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "10:45",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "The Best Nature Scenes in 4K Ultra HD",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "12.3K views • 2 days ago",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),*/

              SliverToBoxAdapter(
                child: SizedBox(height: 10,),
              ),

              /// STICKY TAB BAR
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  const TabBar(
                   // indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.zero,
                    ),                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(text: "Like"),
                      Tab(text: "Comment"),
                      Tab(text: "Product"),
                      Tab(text: "Service"),
                    ],
                  ),
                ),
              ),

            ];
          },

          /// TAB CONTENT
          body: const TabBarView(
            children: [
              VideoGridSection(type: VideoType.like),
              VideoGridSection(type: VideoType.comment),
              VideoGridSection(type: VideoType.product),
              VideoGridSection(type: VideoType.service),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildShimmerSlider() {
    return PageView.builder(
      itemCount: 3,
      controller: PageController(viewportFraction: 0.9),
      padEnds: false,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// SliverPersistentHeader delegate for pinned TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

/// Video grid section for each tab
/*
class VideoGridSection extends StatelessWidget {
  final VideoType type;

  const VideoGridSection({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// THUMBNAIL
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18)),
                      child: Image.network(
                        "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// PLAY ICON
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// TITLE
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Amazing Nature Video",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              /// ICON BASED ON TAB TYPE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildBottomIcon(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomIcon() {
    switch (type) {
      case VideoType.like:
        return _iconWithText(Icons.favorite, "1.2K", color: Colors.red);
      case VideoType.comment:
        return _iconWithText(Icons.comment, "340");
      case VideoType.share:
        return _iconWithText(CupertinoIcons.arrowshape_turn_up_right_fill, "120");
    }
  }

  Widget _iconWithText(IconData icon, String count, {Color color = Colors.black}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
*/



class VideoGridSection extends StatelessWidget {
  final VideoType type;

  const VideoGridSection({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.find<HistoryController>();

    return Obx(() {
      bool isLoading = false;
      List<dynamic> items = [];
      Function() loadMore = () {};
      bool hasMore = false;

      switch (type) {
        case VideoType.like:
          isLoading = controller.isLoadingLikes.value;
          items = controller.likes;
          loadMore = () => controller.fetchLikes(loadMore: true);
          hasMore = controller.hasMoreLikes;
          break;
        case VideoType.comment:
          isLoading = controller.isLoadingComments.value;
          items = controller.comments;
          loadMore = () => controller.fetchComments(loadMore: true);
          hasMore = controller.hasMoreComments;
          break;
        case VideoType.product:
          isLoading = controller.isLoadingPurchases.value;
          items = controller.purchases;
          loadMore = () => controller.fetchPurchases(loadMore: true);
          hasMore = controller.hasMorePurchases;
          break;
        case VideoType.service:
          isLoading = controller.isLoadingServices.value;
          items = controller.services;
          loadMore = () => controller.fetchServices(loadMore: true);
          hasMore = controller.hasMoreServices;
          break;
      }

      if (isLoading && items.isEmpty) {
        return (type == VideoType.product || type == VideoType.service) 
            ? _buildShimmerList() 
            : _buildShimmerGrid();
      }
      
      final Widget content = items.isEmpty
          ? _buildEmptyState("No history found.")
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading && hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  loadMore();
                }
                return false;
              },
              child: (type == VideoType.product || type == VideoType.service)
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildOrderCard(item as PurchaseHistoryItem),
                        );
                      },
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length + (hasMore ? 1 : 0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final item = items[index];
                        return _buildVideoCard(item, type);
                      },
                    ),
            );

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.fetchVideoViews(),
            controller.fetchLikes(),
            controller.fetchComments(),
            controller.fetchPurchases(),
            controller.fetchServices(),
          ]);
        },
        child: content,
      );
    });
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 350,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(PurchaseHistoryItem order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order #${order.orderId}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(order.createdAt, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              order.items.isNotEmpty ? order.items.first.title : "No items",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$${order.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVideoCard(dynamic item, VideoType type) {
    String imageUrl = "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp";
    String title = "Video";
    String sub = "";
    int entityId = 0;

    if (item is LikeHistoryItem) {
      imageUrl = item.preview?.thumbnail ?? imageUrl;
      title = item.preview?.caption ?? "Liked Video";
      sub = item.createdHuman;
      entityId = item.entityId;
    } else if (item is CommentHistoryItem) {
      title = item.body;
      sub = item.createdHuman;
      entityId = item.entityId;
    }

    return GestureDetector(
      onTap: () {
        if (imageUrl.toLowerCase().contains('.mp4')) {
          Get.to(() => VideoPlayerScreen(videoUrl: imageUrl, videoId: entityId));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl.toLowerCase().contains('.mp4')
                  ? FeedVideoPlayer(videoUrl: imageUrl)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
                    ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          if (imageUrl.toLowerCase().contains('.mp4'))
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2)
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                _buildBottomIcon(type),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBottomIcon(VideoType type) {
    switch (type) {
      case VideoType.like:
        return _iconWithText(Icons.favorite, "Liked", color: Colors.red);
      case VideoType.comment:
        return _iconWithText(Icons.comment, "Commented", color: Colors.white);
      case VideoType.product:
        return _iconWithText(Icons.shopping_bag, "Product", color: Colors.white);
      case VideoType.service:
        return _iconWithText(Icons.design_services, "Service", color: Colors.white);
    }
  }

  Widget _iconWithText(IconData icon, String text, {Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}



