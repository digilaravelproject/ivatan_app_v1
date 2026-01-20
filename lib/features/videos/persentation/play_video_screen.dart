import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:iconly/iconly.dart';
import 'package:video_player/video_player.dart';

import '../../../core/helper/video_play.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../dashboard/model/post_model.dart';
import '../../dashboard/persentation/home_screen.dart';
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
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
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
      if (Get.isRegistered<VideoController>(tag: oldWidget.videoId.toString())) {
        Get.delete<VideoController>(tag: oldWidget.videoId.toString());
      }

      // Initialize new video controller
      _controller = VideoPlayerController.network(widget.videoUrl)
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Video Player Section
          /*Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.black,
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
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {},
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.trending_up, size: 20),
                            ),
                            SizedBox(width: 12),
                            Stack(
                              children: [
                                Icon(Icons.notifications, color: Colors.white, size: 28),
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
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              color: Colors.white,
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
                      icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
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
                          color: Colors.white,
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
                      icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
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
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(_controller.value.position)
                            : '0.00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
                          inactiveColor: Colors.white30,
                        ),
                      ),
                      Text(
                        _controller.value.isInitialized
                            ? _formatDuration(_controller.value.duration)
                            : '5.00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.fullscreen, color: Colors.white, size: 20),
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
                child: WorkOutVideoPlayPage(videoUrl: widget.videoUrl),
                //child: WorkOutVideoPlayPage(videoUrl: controller.),
              ),

             /* SizedBox(
                height: AppSizer.deviceHeight26,
                child: Obx(() {
                  final video = controller.currentVideo.value;

                  if (video == null || video.media.isEmpty || video.media.first.url == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // ✅ Video available hai, tabhi player call karo
                  return WorkOutVideoPlayPage(videoUrl: video.media.first.url!);
                }),
              ),*/


              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
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
                                  Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '1,25,678  13 May 22',
                                    style: TextStyle(
                                      color: Colors.grey,
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
                              color: Colors.white,
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
                                  color: Colors.white,
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
                        color: Colors.grey,
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
                                  color: Colors.white,
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
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '05:00',
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
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                                    SizedBox(width: 2),
                                    Text('9.5M', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    SizedBox(width: 8),
                                    Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey),
                                    SizedBox(width: 2),
                                    Text('2.5M', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    SizedBox(width: 8),
                                    Icon(Icons.thumb_down_outlined, size: 14, color: Colors.grey),
                                    SizedBox(width: 2),
                                    Text('2.5M', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {},
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
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "No related videos found",
                          style: TextStyle(color: Colors.grey),
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

                              final videoUrl = item.media.isNotEmpty
                                  ? item.media.first.url ?? ""
                                  : "";
                              if (videoUrl.isEmpty) return;

                              if (Get.isRegistered<VideoController>(tag: item.id.toString())) {
                                Get.delete<VideoController>(tag: item.id.toString());
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
                                        color: Colors.white,
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
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          "item.duration " ?? "00:00",
                                          style: const TextStyle(
                                            color: Colors.white,
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
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.remove_red_eye,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.viewCount?.toString() ??
                                                "0",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.thumb_up_outlined,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.likeCount?.toString() ??
                                                "0",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.comment,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item.stats.commentCount
                                                    ?.toString() ??
                                                "0",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {},
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
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    video.user.avatar.isNotEmpty
                        ? video.user.avatar
                        : 'https://i.pravatar.cc/100?img=5',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.caption,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${video.stats.viewCount}  ${video.createdHuman}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (!video.is_mine) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (video.user.id != null) {
                        controller.toggleFollowForPostUser(video.user.id!);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        video.is_following ? 'Followed' : 'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        video.stats.likeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: CustomIcon(
                    svgString: AppIcons.ic_comments,
                    color: Colors.black,
                    size: 20,
                    removeColor: false,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsBottomSheet(postId: video.id),
                    );
                  },
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: const Icon(IconlyLight.send, color: Colors.black, size: 26),
                  onPressed: () {},
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.playlist_add, size: 28),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 5),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              video.caption ?? '', // make sure your PostData has description
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(height: 6),

          // Maybe you like this / suggestions (optional)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Maybe you like that',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
         // SizedBox(height: 5),
        ],
      );
    });
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Video Player Section
          Stack(
            children: [
              Container(
                height: 500,
                width: double.infinity,
                color: Colors.black,
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
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.trending_up, size: 20),
                            ),
                            SizedBox(width: 12),
                            Stack(
                              children: [
                                Icon(Icons.notifications,
                                    color: Colors.white, size: 28),
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
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              color: Colors.white,
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
                          color: Colors.white, size: 40),
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
                          color: Colors.white,
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
                          color: Colors.white, size: 40),
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
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Text(
                        _isInitialized
                            ? _formatDuration(_controller.value.position)
                            : '0:00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
                          inactiveColor: Colors.white30,
                        ),
                      ),
                      Text(
                        _isInitialized
                            ? _formatDuration(_controller.value.duration)
                            : '0:00',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Fullscreen logic
                        },
                        child: Icon(Icons.fullscreen,
                            color: Colors.white, size: 20),
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
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    '1,25,678  13 May 22',
                                    style: TextStyle(
                                      color: Colors.grey,
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
                              color: Colors.white,
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
                                  color: Colors.white,
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
                        color: Colors.grey,
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
                                  color: Colors.white,
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
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '05:00',
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
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('9.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    SizedBox(width: 12),
                                    Icon(Icons.thumb_up_outlined,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('2.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    SizedBox(width: 12),
                                    Icon(Icons.thumb_down_outlined,
                                        size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('2.5M',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {},
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
        unselectedItemColor: Colors.grey,
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
