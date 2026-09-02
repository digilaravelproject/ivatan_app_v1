import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/controller/homeController.dart';
import '../../dashboard/model/post_model.dart';
import '../../dashboard/persentation/widgets/feed_post_widget.dart';

class ProfileFeedScreen extends StatefulWidget {
  final List<PostItem> posts;
  final int initialIndex;
  final dynamic controller; // Can be OwnPostController or HomeController

  const ProfileFeedScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
    this.controller,
  }) : super(key: key);

  @override
  State<ProfileFeedScreen> createState() => _ProfileFeedScreenState();
}

class _ProfileFeedScreenState extends State<ProfileFeedScreen> {
  late ScrollController _scrollController;
  late dynamic finalController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Fallback to HomeController if no controller passed
    finalController = widget.controller ?? Get.find<HomeController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (widget.initialIndex > 0 && _scrollController.hasClients) {
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_app.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Posts",
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: widget.controller != null ? Obx(() {
          return _buildList();
        }) : Builder(builder: (context) {
          return _buildList();
        }),
      ),
    );
  }

  Widget _buildList() {
    List<PostItem> displayPosts = [];
    try {
      if (widget.controller != null) {
        displayPosts = finalController.posts;
      } else {
        displayPosts = widget.posts;
      }
    } catch (e) {
      displayPosts = widget.posts;
    }
    
    // If empty from controller, maybe use widget.posts as fallback or show empty
    if (displayPosts.isEmpty && widget.posts.isNotEmpty) {
        displayPosts = widget.posts;
    }

    // Filter out locked exclusive posts so they don't appear in the feed
    displayPosts = displayPosts.where((post) {
        bool isPurchased = post.isPurchased ?? false;
        bool hasAccess = post.hasAccess ?? false;
        bool isLocked = !post.is_mine && !isPurchased && !hasAccess && (post.price != null || post.isExclusive == true);
        return !isLocked;
    }).toList();

    return ListView.builder(
      controller: _scrollController,
      itemCount: displayPosts.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final post = displayPosts[index];
        return FeedPostWidget(
          post: post,
          index: index,
          controller: finalController,
        );
      },
    );
  }
}
