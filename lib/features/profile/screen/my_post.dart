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
                    Get.to(() => ProfileFeedScreen(
                      posts: controller.posts,
                      initialIndex: index,
                    ));
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
