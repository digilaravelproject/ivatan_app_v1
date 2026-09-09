import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/helper/video_play.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../dashboard/model/post_model.dart';
import '../../dashboard/persentation/home_screen.dart';
import '../../dashboard/persentation/comming_soon.dart'; // For CustomEmptyState
import '../../reels_screen/persentation/reels_view.dart';
import '../controller/video_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final int videoId;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoId,
  });
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showMenu = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize with a sample video URL
  //   _controller = VideoPlayerController.network(
  //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  //   )..initialize().then((_) {
  //     setState(() {});
  //   });
  // }

  late VideoController controller;
  @override
  void initState() {
    super.initState();
    final bool isPassedUrlValid =
        widget.videoUrl.isNotEmpty &&
        widget.videoUrl.toLowerCase().contains('.mp4');
    final String playUrl =
        isPassedUrlValid
            ? widget.videoUrl
            : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    _controller = VideoPlayerController.network(playUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });

    // Controller yahan initialize karo
    controller = Get.put(
      VideoController(videoId: widget.videoId),
      tag: widget.videoId.toString(),
    );
  }

  /* @override
  void initState() {
    super.initState();

    controller = Get.put(
      VideoController(videoId: widget.videoId),
      tag: widget.videoId.toString(),
    );

    ever(controller.currentVideo, (PostItem? video) {
      if (video != null && video.media.first.url != null) {
        _controller?.dispose();

        _controller = VideoPlayerController.network(video.media.first.url!)
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
          });
      }
    });
  }*/

  /*@override
  void didUpdateWidget(VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      // Video change hui hai
      _controller.dispose();
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) => setState(() {}));

      // ✅ Purana controller delete aur naya create
      Get.delete<VideoController>(tag: oldWidget.videoId.toString());
      controller = Get.put(
        VideoController(videoId: widget.videoId),
        tag: widget.videoId.toString(),
      );
    }
  }*/

  @override
  void didUpdateWidget(VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      // Dispose old video controller
      _controller.dispose();

      // Delete old VideoController explicitly
      if (Get.isRegistered<VideoController>(
        tag: oldWidget.videoId.toString(),
      )) {
        Get.delete<VideoController>(tag: oldWidget.videoId.toString());
      }

      final bool isPassedUrlValid =
          widget.videoUrl.isNotEmpty &&
          widget.videoUrl.toLowerCase().contains('.mp4');
      final String playUrl =
          isPassedUrlValid
              ? widget.videoUrl
              : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      // Initialize new video controller
      _controller = VideoPlayerController.network(playUrl)
        ..initialize().then((_) => setState(() {}));

      controller = Get.put(
        VideoController(videoId: widget.videoId),
        tag: widget.videoId.toString(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    Get.delete<VideoController>(tag: widget.videoId.toString()); // ✅ Cleanup
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes.$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Column(
        children: [
          // Video Player Section
          /*Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: AppColors.white,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyan,
                  ),
                ),
              ),
              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.white,
                        AppColors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: AppColors.white),
                          onPressed: () {},
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.trending_up, size: 20),
                            ),
                            SizedBox(width: 12),
                            Stack(
                              children: [
                                Icon(Icons.notifications, color: AppColors.white, size: 28),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            PopupMenuButton(
                              tooltip: '',
                              icon: Icon(Icons.more_vert, color: AppColors.white),
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed, size: 20),
                                      SizedBox(width: 12),
                                      Text('Speed'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune, size: 20),
                                      SizedBox(width: 12),
                                      Text('Quality'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag_outlined, size: 20),
                                      SizedBox(width: 12),
                                      Text('Report'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, size: 20),
                                      SizedBox(width: 12),
                                      Text('Save'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.block, size: 20),
                                      SizedBox(width: 12),
                                      Text('Block'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Video Controls
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: AppColors.white, size: 40),
                      onPressed: () {
                        _controller.seekTo(Duration.zero);
                      },
                    ),
                    SizedBox(width: 24),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.teal,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: AppColors.white, size: 40),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Video Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(_controller.value.position)
                            : '0.00',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          value: _controller.value.isInitialized
                              ? _controller.value.position.inSeconds.toDouble()
                              : 0,
                          max: _controller.value.isInitialized
                              ? _controller.value.duration.inSeconds.toDouble()
                              : 100,
                          onChanged: (value) {
                            setState(() {
                              _controller.seekTo(Duration(seconds: value.toInt()));
                            });
                          },
                          activeColor: Colors.red,
                          inactiveColor: AppColors.white.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(_controller.value.duration)
                            : '5.00',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.fullscreen, color: AppColors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),*/
          Stack(
            children: [
              SizedBox(
                height: AppSizer.deviceHeight26,
                child: Obx(() {
                  final video = controller.currentVideo.value;
                  final bool isPassedUrlValid =
                      widget.videoUrl.isNotEmpty &&
                      widget.videoUrl.toLowerCase().contains('.mp4');

                  if (isPassedUrlValid) {
                    return WorkOutVideoPlayPage(videoUrl: widget.videoUrl);
                  }

                  if (video == null || video.media.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.cyan),
                    );
                  }

                  return WorkOutVideoPlayPage(videoUrl: video.media.first.url);
                }),
              ),

              Positioned(
                top: 0,
                left: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          /*SizedBox(
            height: AppSizer.deviceHeight26,
              child: WorkOutVideoPlayPage(videoUrl: widget.videoUrl,)
          ),*/
          //https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _videoContentSection(),
                  /*Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=5',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to find love',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.remove_red_eye, size: 14, color: AppColors.premiumGold),
                                  SizedBox(width: 4),
                                  Text(
                                    '1,25,678  13 May 22',
                                    style: TextStyle(
                                      color: AppColors.premiumGold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Followed',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Engagement Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text('💖', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                '2.4M',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline, size: 28),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.share, size: 28),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.playlist_add, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'It is a long established fact that a reader will be not to be distracted by the readable content of a page when looking at its layout.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Maybe you like that',
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 14,
                      ),
                    ),
                  ),*/
                  SizedBox(height: 5),

                  // Video List
                  /* ...List.generate(3, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://picsum.photos/280/200?random=$index',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow, color: Colors.red, size: 24),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '05:00',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Lord of the Rings: The Fellowship of the Dragon',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Creator, Influencer',
                                  style: TextStyle(
                                    color: AppColors.premiumGold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye, size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 2),
                                    Text('9.5M', style: TextStyle(fontSize: 11, color: AppColors.premiumGold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 2),
                                    Text('2.5M', style: TextStyle(fontSize: 11, color: AppColors.premiumGold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.thumb_down_outlined, size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 2),
                                    Text('2.5M', style: TextStyle(fontSize: 11, color: AppColors.premiumGold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    );
                  }),*/
                  Obx(() {
                    // if (controller.isLoading.value) {
                    //   return const Center(child: CircularProgressIndicator());
                    // }

                    if (controller.relatedVideoList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomEmptyState(
                          title: "No Related Videos",
                          subTitle: "Check back later for more content",
                          icon: Icons.video_library_rounded,
                          isSmall: true,
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(controller.relatedVideoList.length, (
                        index,
                      ) {
                        final item = controller.relatedVideoList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: () {
                              final videoUrl =
                                  item.media.isNotEmpty
                                      ? item.media.first.url ?? ""
                                      : "";
                              if (videoUrl.isEmpty) return;

                              if (Get.isRegistered<VideoController>(
                                tag: item.id.toString(),
                              )) {
                                Get.delete<VideoController>(
                                  tag: item.id.toString(),
                                );
                              }

                              Get.off(
                                () => VideoPlayerScreen(
                                  key: ValueKey(item.id),
                                  videoUrl: videoUrl,
                                  videoId: item.id,
                                ),
                                preventDuplicates: false,
                              );
                            },
                            child: Row(
                              children: [
                                /// Thumbnail + Play icon
                                // InkWell(
                                //   onTap: () {
                                //     // 👉 open selected related video
                                //     Get.to(
                                //           () => VideoPlayerScreen(
                                //         videoUrl: item.media.first.url.toString(),
                                //         videoId: item.id!,
                                //       ),
                                //       arguments: item.id,
                                //     );
                                //   },
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            item.media.first.thumbnail ??
                                                "https://via.placeholder.com/300",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.black.withOpacity(
                                            0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "item.duration " ?? "00:00",
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 12),

                                /// Right content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.caption ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.user?.name ?? "",
                                        style: TextStyle(
                                          color: AppColors.premiumGold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            size: 14,
                                            color: AppColors.premiumGold,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.viewCount?.toString() ??
                                                "0",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.premiumGold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.thumb_up_outlined,
                                            size: 14,
                                            color: AppColors.premiumGold,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.likeCount?.toString() ??
                                                "0",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.premiumGold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.comment,
                                            size: 14,
                                            color: AppColors.premiumGold,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.commentCount
                                                    ?.toString() ??
                                                "0",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.premiumGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoContentSection() {
    return Obx(() {
      final video = controller.currentVideo.value;

      if (controller.isLoading.value || video == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.premiumGold,
                  backgroundImage: NetworkImage(
                    video.user.avatar.isNotEmpty
                        ? video.user.avatar
                        : 'https://i.pravatar.cc/100?img=5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_rounded,
                            size: 13,
                            color: AppColors.premiumGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${video.stats.viewCount} views • ${video.createdHuman}',
                            style: TextStyle(
                              color: AppColors.premiumGold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (!video.is_mine) ...{
                  const SizedBox(width: 8),
                  Obx(() {
                    final isFollowing =
                        controller.followController
                            .isUserFollowing(
                              video.user.id!,
                              initialValue: video.is_following,
                            )
                            .value;

                    return GestureDetector(
                      onTap: () {
                        if (isFollowing) {
                          _showUnfollowBottomSheet(video.user);
                        } else {
                          controller.toggleFollowForPostUser(video.user.id!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isFollowing
                                  ? AppColors.premiumGold
                                  : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            color:
                                isFollowing ? AppColors.white : AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                },
              ],
            ),
          ),

          // Video Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              video.caption,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Engagement Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Like Button
                _buildActionButton(
                  icon:
                      video.stats.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                  label: _formatCount(video.stats.likeCount),
                  isActive: video.stats.isLiked,
                  onTap: () {
                    controller.likeVideo(video.id);
                  },
                ),
                const SizedBox(width: 12),
                // Comment Button
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: _formatCount(video.stats.commentCount),
                  isActive: false,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparent,
                      builder: (_) => CommentsBottomSheet(postId: video.id),
                    );
                  },
                ),
                const Spacer(),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 24),
                  color: AppColors.premiumGold,
                  onPressed: () {},
                ),
                // Bookmark Button
                IconButton(
                  icon: Icon(
                    video.stats.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 24,
                    color:
                        video.stats.isSaved
                            ? AppColors.white
                            : AppColors.premiumGold,
                  ),
                  onPressed: () {
                    controller.toggleBookmark(video.id);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Divider(height: 1, color: AppColors.premiumGold),

          const SizedBox(height: 16),

          // Related Videos Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Related Videos',
              style: TextStyle(
                color: AppColors.premiumGold,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppColors.premiumGold.withOpacity(0.2)
                  : AppColors.transparent,
          border: Border.all(color: AppColors.premiumGold),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.premiumGold),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.premiumGold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnfollowBottomSheet(dynamic user) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 20, bottom: 20 + bottomPadding),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.premiumGold,
              backgroundImage:
                  user.avatar != null && user.avatar!.isNotEmpty
                      ? NetworkImage(user.avatar!)
                      : null,
              child:
                  (user.avatar == null || user.avatar!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              "Unfollow @${user.username}?",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 32),
            ListTile(
              title: const Center(
                child: Text(
                  "Unfollow",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Get.back();
                controller.toggleFollowForPostUser(user.id!);
              },
            ),
            const Divider(),
            ListTile(
              title: const Center(child: Text("Cancel")),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/*
class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(
      'https://www.youtube.com/watch?v=emjnJVdSMh0&list=RDemjnJVdSMh0&start_radio=1',
    );

    // Video initialize hone par listener add karein
    await _controller.initialize();

    // Video player ke state changes ko listen karein
    _controller.addListener(() {
      setState(() {});
    });

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Column(
        children: [
          // Video Player Section
          Stack(
            children: [
              Container(
                height: 500,
                width: double.infinity,
                color: AppColors.white,
                child: _isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyan,
                  ),
                ),
              ),
              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.white,
                        AppColors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: AppColors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.trending_up, size: 20),
                            ),
                            SizedBox(width: 12),
                            Stack(
                              children: [
                                Icon(Icons.notifications,
                                    color: AppColors.white, size: 28),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.cyan,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            PopupMenuButton(
                              tooltip: '',
                              icon: Icon(Icons.more_vert, color: AppColors.white),
                              color: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.speed, size: 20),
                                      SizedBox(width: 12),
                                      Text('Speed'),
                                    ],
                                  ),
                                  onTap: () {
                                    // Speed change logic
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune, size: 20),
                                      SizedBox(width: 12),
                                      Text('Quality'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag_outlined, size: 20),
                                      SizedBox(width: 12),
                                      Text('Report'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, size: 20),
                                      SizedBox(width: 12),
                                      Text('Save'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.block, size: 20),
                                      SizedBox(width: 12),
                                      Text('Block'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Video Controls
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous,
                          color: AppColors.white, size: 40),
                      onPressed: () {
                        final currentPosition = _controller.value.position;
                        final newPosition = currentPosition - Duration(seconds: 10);
                        _controller.seekTo(
                          newPosition < Duration.zero ? Duration.zero : newPosition,
                        );
                      },
                    ),
                    SizedBox(width: 24),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.teal,
                          size: 32,
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    IconButton(
                      icon: Icon(Icons.skip_next,
                          color: AppColors.white, size: 40),
                      onPressed: () {
                        final currentPosition = _controller.value.position;
                        final newPosition = currentPosition + Duration(seconds: 10);
                        final duration = _controller.value.duration;
                        _controller.seekTo(
                          newPosition > duration ? duration : newPosition,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Video Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Text(
                        _isInitialized
                            ? _formatDuration(_controller.value.position)
                            : '0:00',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          value: _isInitialized && _controller.value.duration.inSeconds > 0
                              ? _controller.value.position.inSeconds.toDouble()
                              : 0,
                          max: _isInitialized
                              ? _controller.value.duration.inSeconds.toDouble()
                              : 100,
                          onChanged: (value) {
                            _controller.seekTo(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.red,
                          inactiveColor: AppColors.white.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        _isInitialized
                            ? _formatDuration(_controller.value.duration)
                            : '0:00',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Fullscreen logic
                        },
                        child: Icon(Icons.fullscreen,
                            color: AppColors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=5',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to find love',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.remove_red_eye,
                                      size: 14, color: AppColors.premiumGold),
                                  SizedBox(width: 4),
                                  Text(
                                    '1,25,678  13 May 22',
                                    style: TextStyle(
                                      color: AppColors.premiumGold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Followed',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Engagement Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text('💖', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(
                                '2.4M',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline, size: 28),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.share, size: 28),
                          onPressed: () {},
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.playlist_add, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'It is a long established fact that a reader will be not to be distracted by the readable content of a page when looking at its layout.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Maybe you like that',
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Video List
                  ...List.generate(3, (index) {
                    return Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://picsum.photos/280/200?random=$index',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow,
                                    color: Colors.red, size: 24),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '05:00',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The Lord of the Rings: The Fellowship of the Dragon',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Creator, Influencer',
                                  style: TextStyle(
                                    color: AppColors.premiumGold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye,
                                        size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 4),
                                    Text('9.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: AppColors.premiumGold)),
                                    SizedBox(width: 12),
                                    Icon(Icons.thumb_up_outlined,
                                        size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 4),
                                    Text('2.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: AppColors.premiumGold)),
                                    SizedBox(width: 12),
                                    Icon(Icons.thumb_down_outlined,
                                        size: 14, color: AppColors.premiumGold),
                                    SizedBox(width: 4),
                                    Text('2.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: AppColors.premiumGold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: AppColors.premiumGold,
        currentIndex: 3,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      ),
    );
  }
}*/
