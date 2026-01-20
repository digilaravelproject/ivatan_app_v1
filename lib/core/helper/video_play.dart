import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/app_assets.dart';

class WorkOutVideoPlayPage extends StatefulWidget {
  //const WorkOutVideoPlayPage({super.key});
  final String videoUrl;   // ← yaha link milega

  const WorkOutVideoPlayPage({
    super.key,
    required this.videoUrl,
  });

  @override
  State<WorkOutVideoPlayPage> createState() => _WorkOutVideoPlayPageState();
}

class _WorkOutVideoPlayPageState extends State<WorkOutVideoPlayPage> {

  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;

 /* @override
  void initState() {
    const BetterPlayerConfiguration betterPlayerConfiguration =
    BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ],
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    super.initState();
  }*/

  @override
  void initState() {
    super.initState();

    const config = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
    );

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );

    _betterPlayerController = BetterPlayerController(config);
    _betterPlayerController.setupDataSource(dataSource);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
     //   leadingWidth: AppDimens.leadingWidth,
        leading: IconButton(
          onPressed: Get.back,
        //  icon: Icon(AppAssets.backArrow),
          icon: Icon(Icons.arrow_forward_outlined),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.music_note_sharp)),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
          ).marginOnly(left: 12, right: 12),
        ],
      ),*/
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: _betterPlayerController),
          ),
          /*Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "01:00",
                    style: context.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 42,
                    ),
                  ),
                  Text(
                    "Exercise Name",
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.textTheme.bodySmall?.color,
                    ),
                  ).marginOnly(top: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: CustomImageView(
                      //     svgPath: AppAssets.backword,
                      //     height: 16,
                      //     width: 16,
                      //     color: context.theme.iconTheme.color,
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.play_arrow_rounded),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: CustomImageView(
                      //     svgPath: AppAssets.forward,
                      //     height: 16,
                      //     width: 16,
                      //     color: context.theme.iconTheme.color,
                      //   ),
                      // ),
                    ],
                  ).marginOnly(top: 30),
                ],
              ),
            ),
          ),*/
        ],
      ),
    /*  bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: context.mediaQueryPadding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Exercises 1/11",
                style: context.textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),*/
    );
  }
}