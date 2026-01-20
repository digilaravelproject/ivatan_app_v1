import 'package:cached_network_image/cached_network_image.dart';
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

class SerachScreen extends StatefulWidget {
  const SerachScreen({super.key});

  @override
  State<SerachScreen> createState() => _SerachScreenState();
}

class _SerachScreenState extends State<SerachScreen> {
  List<String> sliderImages = [
    "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg",
    "https://images.pexels.com/photos/34950/pexels-photo.jpg",
    "https://images.pexels.com/photos/248797/pexels-photo-248797.jpeg",
  ];
  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    final PostController controller = Get.put(PostController());

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:AppColors.lightBackgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body:  Column(
            children: [
              SizedBox(height: kToolbarHeight * 0.65),
              CustomSearchBar(),
              SizedBox(
                height: 130,
                child:Obx((){
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.bannersList.isEmpty) {
                    return const Center(child: Text("No banners found"));
                  }
                  return ImageSlider(
                    images: controller.bannersList
                        .map((banner) => banner.mediaUrl)
                        .toList(),
                    viewPort: 0.9, // size of each sliding item
                    borderRadius: 16, // round corner
                    autoScroll: true, // auto move the slider
                    isIndicatorVisible: true, // show dots
                    itemPadding: EdgeInsets.symmetric(horizontal: 8),
                    indicatorAlignment: MainAxisAlignment.center,
                  );
                })

              ),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        //   controller: _tabController,
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(),
                        labelColor: Colors.blue,
                        tabAlignment: TabAlignment.start,
                        unselectedLabelColor: AppColors.black,
                        labelPadding: EdgeInsets.symmetric(horizontal: 8),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up_outlined),
                                SizedBox(width: 5),
                                Text("Trending",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomImageView(
                                  imagePath: AppAssets.imgLive,
                                  height: 30,
                                  width: 30,
                                ),
                                SizedBox(width: 5),
                                Text("Live",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border),
                                SizedBox(width: 5),
                                Text("For You",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),

                    ///  SizedBox(height: 20),

                      /// ---------- TAB BAR VIEW (DIFFERENT SCREENS) ----------
                      Expanded(
                       // height: 500, // required
                        child: TabBarView(
                          children: [
                          //  LiveScreen(),
                           TrendingScreen(),
                          Center(child: Text("Coming Soon",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
                          Center(child: Text("Coming Soon",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),)
                          // LiveScreen(),
                          // ForYouScreen(),
                           // ReelsScreen()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_outlined),
                    SizedBox(width: 5,),
                    Text("Trending",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                    CustomImageView(imagePath: AppAssets.imgLive,height: 28,width: 28,),
                    SizedBox(width: 5,),
                    Text("Live",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(width: 10,),
                    Icon(Icons.keyboard_arrow_down_sharp),
                    SizedBox(width: 5,),
                    Text("For You",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  ],
                ),
              )*/
            ],
          ),

      ),
    );
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
    return Container(
      color: AppColors.transparent,
        child: Column(
          children: [
           /* SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildStoryItem('https://images.pexels.com/photos/34950/pexels-photo.jpg');
                },
              ),
            ),*/

            Padding(
             padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 130,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (controller.intrestedPostList.isEmpty) {
                    return Center(child: Text("Trending not found"));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:  const EdgeInsets.symmetric(horizontal: 12), // remove extra padding
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.posts.isEmpty) {
                    return const Center(child: Text("No posts found"));
                  }
                  return MasonryGridView.count(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: controller.posts.length,
                    itemBuilder: (context, index) {
                      final item = controller.posts[index];

                      // THUMBNAIL LOGIC
                      final String thumb = (item.media.isNotEmpty)
                          ? (item.media.first.thumbnail.isNotEmpty
                          ? item.media.first.thumbnail
                          : item.media.first.url) // fallback
                          : "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg";             // No image fallback

                      return GestureDetector(
                        onTap: () {
                          if (item.media.first.type == "video") {
                            Get.to(() => VideoPlayerScreen(videoUrl: item.media.first.url, videoId: item.id, ));//url: item.media.first.url
                          }
                          else if (item.media.first.type == "reel") {
                          //  Get.to(() => ReelPlayerScreen(url: item.media.first.url));
                          }
                          else if (item.media.first.type == "image") {
                            Get.to(()=>ImagePostScreen(postId: item.id,));
                          //  Get.to(() => ImagePreviewScreen(url: item.media.first.url));
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


            /* Expanded(
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
            ),*/
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
                  //  Get.to(() => ReelPlayerScreen(url: item.media.first.url));
                }
                else if (postType == "image") {
                  Get.to(()=>ImagePostScreen(postId: postId,));
                  //  Get.to(() => ImagePreviewScreen(url: item.media.first.url));
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
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
                backgroundImage: NetworkImage(imageUrl),
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

