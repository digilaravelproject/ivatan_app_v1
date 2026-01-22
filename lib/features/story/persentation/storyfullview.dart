import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/features/dashboard/controller/homeController.dart';
import 'package:video_player/video_player.dart';

import '../../auth/widgets/auth_input_fields.dart';
import '../../dashboard/controller/create_story_controller.dart';
import '../../dashboard/model/story_model.dart';
class FullScreenStoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const FullScreenStoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenStoryViewer> createState() => _FullScreenStoryViewerState();
}

class _FullScreenStoryViewerState extends State<FullScreenStoryViewer> {
  late PageController _pageController;
  BetterPlayerController? _betterPlayerController;
  Timer? _progressTimer;

  int currentIndex = 0;
  double progress = 0.0;

  int get selectedStoryId => widget.stories[currentIndex].id;

  bool get isMine => widget.stories[currentIndex].is_mine;
  final TextEditingController messageController = TextEditingController();
  bool showSend = false;
  final FocusNode commentFocus = FocusNode();
  bool imageLoaded = false; // Track if current image is loaded

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _loadStory(currentIndex);
    commentFocus.addListener(() {
      if (commentFocus.hasFocus) {
        _betterPlayerController?.pause();
        _progressTimer?.cancel();
      }
    });
    messageController.addListener(() {
      setState(() {
        showSend = messageController.text.trim().isNotEmpty;
      });
    });
  }

  void _loadStory(int index) async {
    _progressTimer?.cancel();
    progress = 0;
    imageLoaded = false; // Reset for new story

    final story = widget.stories[index];

    if (story.type == "video") {
      // Dispose previous controller
      _betterPlayerController?.dispose();

      // Create new controller
      BetterPlayerConfiguration config = BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fit: BoxFit.contain,
        rotation: 0,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        autoDetectFullscreenAspectRatio: true,
      );

      BetterPlayerDataSource source = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        story.mediaUrl,
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 200 * 1024 * 1024,
          maxCacheFileSize: 50 * 1024 * 1024,
        ),
      );

      _betterPlayerController =
          BetterPlayerController(config, betterPlayerDataSource: source);

      // Video duration detect karenge
      Future.delayed(const Duration(milliseconds: 500), () async {
        final duration = await _betterPlayerController!
            .videoPlayerController!.value.duration;

        _startProgress(duration: duration!.inMilliseconds);
      });

      setState(() {});
    } else {
      // For images, timer will start when image loads (via CachedNetworkImage callback)
      setState(() {});
    }
  }

  void _startProgress({required int duration}) {
    int ms = 0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      ms += 50;
      progress = ms / duration;

      if (progress >= 1) {
        progress = 1;
        timer.cancel();
        _nextStory();
      }

      setState(() {});
    });
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      currentIndex++;
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadStory(currentIndex);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      currentIndex--;
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadStory(currentIndex);
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StoryController storyController = Get.put(StoryController());

    HomeController homeController = Get.put(HomeController());


    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// STORY PAGES
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              final story = widget.stories[index];

              if (story.type == "video") {
                return Center(
                  child: _betterPlayerController != null
                      ? AspectRatio(
                    aspectRatio: 9 / 16,
                    child: BetterPlayer(controller: _betterPlayerController!),
                  )
                      : const CircularProgressIndicator(),
                );
                // return SizedBox.expand(
                //   child: _betterPlayerController != null
                //       ? BetterPlayer(controller: _betterPlayerController!)
                //       : const Center(child: CircularProgressIndicator()),
                // );

              }

              return Center(
                child: CachedNetworkImage(
                  imageUrl: story.mediaUrl,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) {
                    // Image loaded successfully, start timer if not already started
                    if (!imageLoaded) {
                      imageLoaded = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _startProgress(duration: 4000);
                      });
                    }
                    return Image(image: imageProvider, fit: BoxFit.cover);
                  },
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );

              // return SizedBox.expand(
              //   child: Image.network(
              //     story.mediaUrl,
              //     fit: BoxFit.cover,
              //   ),
              // );

            },
          ),


          /// PROGRESS BAR
         /* SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: widget.stories.map((s) {
                  int index = widget.stories.indexOf(s);

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      decoration: BoxDecoration(
                        color: index == currentIndex
                            ? Colors.white
                            : Colors.white38,
                      ),
                      child: index == currentIndex
                          ? FractionallySizedBox(
                        widthFactor: progress,
                        alignment: Alignment.centerLeft,
                        child: Container(color: Colors.white),
                      )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),*/

          /// PROGRESS BAR - Instagram style animated
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: widget.stories.asMap().entries.map((entry) {
                  int index = entry.key;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: index < currentIndex
                              ? 1.0
                              : index == currentIndex
                              ? progress
                              : 0.0,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// TAP AREA
          Positioned.fill(
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final width = MediaQuery.of(context).size.width;

                if (d.globalPosition.dx < width / 2) {
                  _previousStory();
                } else {
                  _nextStory();
                }
              },
              onLongPressStart: (_) {
                _betterPlayerController?.pause();
                _progressTimer?.cancel();
              },
              onLongPressEnd: (_) async {
                if (widget.stories[currentIndex].type == "video") {
                  _betterPlayerController?.play();

                  final duration = await _betterPlayerController!
                      .videoPlayerController!.value.duration;

                  _startProgress(duration: duration!.inMilliseconds);
                } else {
                  _startProgress(duration: 20000);
                }
              },
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
              //  margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
                decoration: BoxDecoration(
                  color: AppColors.black // 👈 overlay style
               //   borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: widget.stories[currentIndex].is_mine
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){
                        //Get.back(closeOverlays: true);
                        storyController.showMoreOption();
                        _betterPlayerController?.pause();
                        _progressTimer?.cancel();
                          storyController.currentStoryId = widget.stories[currentIndex].id;
                         // storyController.showMoreOption();
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.more_vert, color: Colors.white, size: 24),
                          SizedBox(height: 4),
                          Text("More", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                )
                : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: commentFocus,
                        controller: messageController,
                        onChanged: (value) {
                          setState(() {
                            showSend = value.trim().isNotEmpty; // 👈 text likhte ही send show
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Send a message",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          suffixIcon: showSend
                              ? GestureDetector(
                            onTap: () {
                              storyController.createComment(
                                storyId: selectedStoryId,
                                body: messageController.text,
                              );
                              messageController.clear();
                              FocusScope.of(context).unfocus();
                              setState(() => showSend = false);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.send, color: Colors.white, size: 26),
                            ),
                          )
                              : const Padding(
                            padding: EdgeInsets.only(right: 10),
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: () async {
                        await homeController.likeStory(selectedStoryId);
                        setState(() {}); // UI update
                      },
                      child: Icon(
                        widget.stories[currentIndex].isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.stories[currentIndex].isLiked ? Colors.red : Colors.white,
                        size: 26,
                      ),
                    ),

                    //  Icon(Icons.favorite_border, color: Colors.white, size: 24),

                  ],)
              ),
            ),
          ),

        ],
      ),
    );
  }
}



/*class FullScreenStoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const FullScreenStoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenStoryViewer> createState() => _FullScreenStoryViewerState();
}

class _FullScreenStoryViewerState extends State<FullScreenStoryViewer>
{
  late PageController _pageController;
  VideoPlayerController? _videoController;
  Timer? _progressTimer;

  int currentIndex = 0;
  double progress = 0.0; // 0 → 1

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);

    _loadStory(currentIndex);
  }

  void _loadStory(int index) async {
    _progressTimer?.cancel();
    progress = 0;

    final story = widget.stories[index];

    if (story.type=="video") {
      _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl));

      await _videoController!.initialize();
      _videoController!.play();

      setState(() {});

      _startProgress(duration: _videoController!.value.duration.inMilliseconds);
    }
    else {
      _startProgress(duration: 4000); // image = 4 sec
    }
  }

  void _startProgress({required int duration}) {
    int ms = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      ms += 50;
      progress = ms / duration;

      if (progress >= 1) {
        progress = 1;
        timer.cancel();
        _nextStory();
      }
      setState(() {});
    });
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      currentIndex++;
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadStory(currentIndex);
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      currentIndex--;
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _loadStory(currentIndex);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// STORY PAGES
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              final story = widget.stories[index];

              if (story.type=="video") {
                return Center(
                  child: _videoController != null &&
                      _videoController!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                      : const CircularProgressIndicator(),
                );
              }
              return Center(
                child: Image.network(
                  story.mediaUrl,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          /// PROGRESS BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: widget.stories.map((s) {
                  int index = widget.stories.indexOf(s);

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 3,
                      decoration: BoxDecoration(
                        color:
                        index == currentIndex ? Colors.white : Colors.white38,
                      ),
                      child: index == currentIndex
                          ? FractionallySizedBox(
                        widthFactor: progress,
                        alignment: Alignment.centerLeft,
                        child: Container(color: Colors.white),
                      )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// LEFT TAP → PREVIOUS \ RIGHT TAP → NEXT
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final width = MediaQuery.of(context).size.width;

              if (d.globalPosition.dx < width / 2) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            onLongPressStart: (_) {
              _videoController?.pause();
              _progressTimer?.cancel();
            },
            onLongPressEnd: (_) {
              if (widget.stories[currentIndex].type=="video") {
                _videoController?.play();
                _startProgress(
                  duration: _videoController!.value.duration.inMilliseconds,
                );
              } else {
                _startProgress(duration: 4000);
              }
            },
          ),
        ],
      ),
    );
  }
}*/