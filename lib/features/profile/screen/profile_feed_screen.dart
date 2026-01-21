import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/controller/homeController.dart';
import '../../dashboard/model/post_model.dart';
import '../../dashboard/persentation/widgets/feed_post_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final List<PostItem> posts;
  final int initialIndex;

  const ProfileFeedScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ProfileFeedScreen> createState() => _ProfileFeedScreenState();
}

class _ProfileFeedScreenState extends State<ProfileFeedScreen> {
  // Using autoscroll to index is hard without fixed heights or a package.
  // We will try a best-effort approach or just standard list.
  late ScrollController _scrollController;
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Use a unique key for each item context? No.
    // We'll just define the controller.
    _scrollController = ScrollController();
    
    // Attempt to scroll to index using estimated height (e.g., 400px per post).
    // This is not perfect but better than top.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.initialIndex > 0 && _scrollController.hasClients) {
         // This is a rough estimate. 
         // post height = header(60) + image(300-400) + actions(50) + text(~50) ~= 500
         double estimatedOffset = widget.initialIndex * 500.0; 
         _scrollController.jumpTo(estimatedOffset);
       }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Posts",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        padding: const EdgeInsets.only(bottom: 20),
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          // Pass formatted index if needed, or just actual index
          return FeedPostWidget(
            post: post,
            index: index,
            controller: homeController,
          );
        },
      ),
    );
  }
}
