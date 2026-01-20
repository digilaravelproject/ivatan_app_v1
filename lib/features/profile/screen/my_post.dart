import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../search/controller/mixed_feed_controller.dart';
import '../../videos/persentation/play_video_screen.dart';
import '../controller/ownpostController.dart';

/*class MyPostScreen extends StatelessWidget {
  String username;
  MyPostScreen({Key? key, required this.username}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    print("mypost username : "+username);
    //final OwnPostController controller = Get.put(OwnPostController(filterType: "posts", UserName: username));
    final controller = Get.put(
      OwnPostController(filterType: "posts", UserName: username),
      tag: username.toString(),
      permanent: true,
    );

    return
      // Scaffold(
      // backgroundColor: AppColors.transparent,
      // body:
      NotificationListener<ScrollNotification>(
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
          //  await controller.fetchStories();
          },
          child:
          // SafeArea(
          //   top: false,
          //   child: Column(
          //     children: [
          //      // SizedBox(height: 10,),
          //       Expanded(
          //         child:
                  Padding(
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
                            onTap:(){

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
          //       ),
          //     ],
          //   ),
          // ),
        ),
      );
   // );

  }
}*/



class MyPostScreen extends StatelessWidget {
  String username;
  MyPostScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      OwnPostController(filterType: "posts", UserName: username),
      tag: username.toString(),
      permanent: true,
    );

    return Expanded(
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

            SizedBox(height: 10,);

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
                  onTap: () {},
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

    /* NotificationListener<ScrollNotification>(
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
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.posts.isEmpty) {
            return const Center(child: Text("No posts found"));
          }

          return MasonryGridView.count(
            padding: EdgeInsets.zero, // <-- remove top padding
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
                onTap: () {},
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
    );*/
  }
}
