import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/theme/app_colors.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../controller/ownpostController.dart';

class MyVideoScreen extends StatelessWidget {
  String username;
  MyVideoScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OwnPostController controller = Get.put(OwnPostController(filterType: "videos", UserName: username ));
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: NotificationListener<ScrollNotification>(
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
            //  await controller.fetchStories();
          },
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),

                /// *** ONLY ONE EXPANDED ***
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Obx(() {
                      if (controller.isLoading.value && controller.posts.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.posts.isEmpty) {
                        return const Center(child: Text("No posts found"));
                      }

                      return GridView.builder(
                      //  controller: controller.scrollController,   // OPTIONAL, If needed
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1,
                        ),
                        itemCount: controller.posts.length,
                        itemBuilder: (context, index) {
                          final post = controller.posts[index];
                          return GestureDetector(
                              onTap: () {
                                  Get.to(() => VideoPlayerScreen(
                                    videoUrl: post.media.first.url,
                                    videoId: post.id,
                                  ));
                              },
                              child: profileGridItem(post.media.first.thumbnail)
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
      ),
    );
  }

/*
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!controller.isLoading.value &&
              controller.isMoreDataAvailable.value &&
              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent * 0.8) {
            controller.fetchOwnPosts(loadMore: true);
          }

          return true;
        },
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Expanded(
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.posts.isEmpty) {
                        return const Center(child: Text("No posts found"));
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1,
                        ),
                        itemCount: controller.posts.length,
                        itemBuilder: (context, index) {
                          final post = controller.posts[index];

                          return profileGridItem(post.media.first.thumbnail);
                          // if your API is like post.media.first.path
                          // return profileGridItem(post.media[0].filePath);
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
*/


  Widget profileGridItem(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.topCenter,
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
                Icon(Icons.play_circle_fill,
                    color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  "1.2M",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
