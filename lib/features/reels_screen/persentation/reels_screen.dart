import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';


/*class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late BetterPlayerController _betterPlayerController;

  final List<String> videos = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupPlayer(videos[currentIndex]);
  }

  void _setupPlayer(String url) {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: true,
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _nextVideo() {
    setState(() {
      currentIndex = (currentIndex + 1) % videos.length;
      _setupPlayer(videos[currentIndex]);
    });
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _nextVideo,
        child: Stack(
          children: [
            SizedBox.expand(
              child: BetterPlayer(controller: _betterPlayerController),
            ),
            // Right-side buttons
            Positioned(
              right: 10,
              bottom: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _iconWithText(Icons.storefront, "25"),
                  const SizedBox(height: 20),
                  _iconWithText(Icons.favorite, "125k"),
                  const SizedBox(height: 20),
                  _iconWithText(Icons.comment, "130k"),
                  const SizedBox(height: 20),
                  _iconWithText(Icons.share, "22k"),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=47"), // Profile pic
                  ),
                ],
              ),
            ),
            // Bottom overlay
            Positioned(
              left: 10,
              right: 80,
              bottom: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/150?img=48"),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                  text: "Ashita Patil · ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              TextSpan(
                                  text: "Follow",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.music_note),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "@rushikesh123 it is a long established fact that a reader distracted by....",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.music_note, size: 16),
                      SizedBox(width: 5),
                      Text("Audio.Original"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}*/


import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controller/reel_controller.dart';


class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ReelsController reelsController = Get.put(ReelsController());
  final PageController _pageController = PageController();

  final List<BetterPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();

    reelsController.fetchReels().then((_) {
      if (reelsController.reels.isNotEmpty) {
        // Create controller for each video
        for (var reel in reelsController.reels) {
          _controllers.add(_createController(reel.media[0].url));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _playVideo(0);
        });
      }
    });
  }

  BetterPlayerController _createController(String url) {
    return BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        looping: true,
        fit: BoxFit.cover,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
      ),
    );
  }

  void _playVideo(int index) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (reelsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (reelsController.reels.isEmpty) {
        return const Center(child: Text("No reels available", style: TextStyle(color: Colors.white)));
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: reelsController.reels.length,
          onPageChanged: _playVideo,
          itemBuilder: (context, index) {
            final reel = reelsController.reels[index];

            return Stack(
              children: [
                SizedBox.expand(
                  child: BetterPlayer(controller: _controllers[index]),
                ),

                // Right side buttons
                Positioned(
                  right: 10,
                  bottom: 120,
                  child: Column(
                    children: [
                      // _iconWithText(Icons.favorite, reel.likeCount.toString()),
                      const SizedBox(height: 20),
                      // _iconWithText(Icons.comment, reel.commentCount.toString()),
                    ],
                  ),
                ),

                // Bottom data
                Positioned(
                  left: 10,
                  right: 80,
                  bottom: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reel.user.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        reel.caption,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _iconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}




/*
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final List<String> videos = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
  ];

  final List<BetterPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();

    // Initialize all controllers
    for (var url in videos) {
      _controllers.add(_createController(url));
    }

    // Play the first video after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controllers.isNotEmpty) {
        _playVideo(0);
      }
    });
  }


  BetterPlayerController _createController(String url) {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
    );
    return BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        looping: true,
        fit: BoxFit.cover,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _playVideo(int index) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i == index) {
        _controllers[i].play();
      } else {
        _controllers[i].pause();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: _playVideo,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              SizedBox.expand(
                child: BetterPlayer(controller: _controllers[index]),
              ),
              // Right-side buttons
              Positioned(
                right: 10,
                bottom: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _iconWithText(Icons.storefront, "25"),
                    const SizedBox(height: 20),
                    _iconWithText(Icons.favorite, "125k"),
                    const SizedBox(height: 20),
                    _iconWithText(Icons.comment, "130k"),
                    const SizedBox(height: 20),
                    _iconWithText(Icons.share, "22k"),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=47"), // Profile pic
                    ),
                  ],
                ),
              ),
              // Bottom overlay
              Positioned(
                left: 10,
                right: 80,
                bottom: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=48"),
                          radius: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                    text: "Ashita Patil · ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                TextSpan(
                                    text: "Follow",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.music_note,color: Colors.white,),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "@rushikesh123 it is a long established fact that a reader distracted by....",
                      style: TextStyle(fontSize: 14,color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.music_note, size: 16,color: Colors.white,),
                        SizedBox(width: 5),
                        Text("Audio.Original",style: TextStyle(fontSize: 14,color: Colors.white),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _iconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
*/


