import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../../core/theme/app_colors.dart';
import '../../dashboard/controller/create_story_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/model/story_model.dart';

class HighlightScreenStoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final int highlightId;

  const HighlightScreenStoryViewer({
    super.key,
    required this.highlightId,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<HighlightScreenStoryViewer> createState() => _HighlightScreenStoryViewerState();
}

class _HighlightScreenStoryViewerState extends State<HighlightScreenStoryViewer> {
  late PageController _pageController;
  BetterPlayerController? _betterPlayerController;
  Timer? _progressTimer;

  int currentIndex = 0;
  double progress = 0.0;

  int get selectedStoryId => widget.stories[currentIndex].id;
  int get highlightId => widget.highlightId;

  bool get isMine => widget.stories[currentIndex].is_mine;
  final TextEditingController messageController = TextEditingController();
  bool showSend = false;
  final FocusNode commentFocus = FocusNode();


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
      _startProgress(duration: 4000); // image 4 sec
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
      backgroundColor: AppColors.transparent,
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
                child: Image.network(
                  story.mediaUrl,
                  fit: BoxFit.cover,
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
                        color: index == currentIndex
                            ? AppColors.white
                            : AppColors.white,
                      ),
                      child: index == currentIndex
                          ? FractionallySizedBox(
                        widthFactor: progress,
                        alignment: Alignment.centerLeft,
                        child: Container(color: AppColors.white),
                      )
                          : null,
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
                  _startProgress(duration: 10000);
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
                          storyController.currentHighlightId = widget.highlightId;
                          storyController.currentStoryId = widget.stories[currentIndex].id;
                          storyController.showMoreOption();
                          _betterPlayerController?.pause();
                          _progressTimer?.cancel();
                          // storyController.showMoreOption();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.more_vert, color: AppColors.white, size: 24),
                            SizedBox(height: 4),
                            Text("More", style: TextStyle(color: AppColors.white,fontWeight: FontWeight.bold,fontSize: 14)),
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
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            hintText: "Send a message",
                            hintStyle: const TextStyle(color: AppColors.white),
                            filled: true,
                            fillColor: AppColors.transparent,
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
                                child: Icon(Icons.send, color: AppColors.white, size: 26),
                              ),
                            )
                                : const Padding(
                              padding: EdgeInsets.only(right: 10),
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.white,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: AppColors.white,
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
                          color: widget.stories[currentIndex].isLiked ? Colors.red : AppColors.white,
                          size: 26,
                        ),
                      ),

                      //  Icon(Icons.favorite_border, color: AppColors.white, size: 24),

                    ],)
              ),
            ),
          ),

        ],
      ),
    );
  }
}