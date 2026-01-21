import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../controller/create_story_controller.dart';
import 'createStoryScreen.dart';

class StoryCameraScreen extends StatelessWidget {
  const StoryCameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.find<StoryController>();

    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          initialCaptureMode: CaptureMode.photo,
          photoPathBuilder: (sensors) async {
            
            final Directory extDir = await getTemporaryDirectory();
            final testDir = await Directory(
              '${extDir.path}/camerawesome',
            ).create(recursive: true);
            final filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
            return SingleCaptureRequest(filePath, sensors.first);
          },
          videoOptions: VideoOptions(
            enableAudio: true,
            ios: CupertinoVideoOptions(fps: 30),
            android: AndroidVideoOptions(
              bitrate: 6000000,
              fallbackStrategy: QualityFallbackStrategy.lower,
            ),
          ),
          videoPathBuilder: (sensors) async {
            final Directory extDir = await getTemporaryDirectory();
            final testDir = await Directory(
              '${extDir.path}/camerawesome',
            ).create(recursive: true);
            final filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
            return SingleCaptureRequest(filePath, sensors.first);
          },
          exifPreferences: ExifPreferences(saveGPSLocation: false),
        ),
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          flashMode: FlashMode.auto,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          zoom: 0.0,
        ),
        enablePhysicalButton: true,
        previewAlignment: Alignment.center,
        previewFit: CameraPreviewFit.cover,
        onMediaCaptureEvent: (event) {
          print('📸 Media capture event: ${event.status}');
          
          if (event.status == MediaCaptureStatus.success) {
            print('✅ Media captured successfully!');
            event.captureRequest.when(
              single: (single) async {
                if (single.file != null) {
                  final file = single.file!;
                  print('📁 File saved: ${file.path}');
                  
                  if (event.isPicture) {
                    controller.imageFile.value = File(file.path);
                    controller.videoFile.value = null;
                  } else if (event.isVideo) {
                    controller.videoFile.value = File(file.path);
                    controller.imageFile.value = null;
                    
                    final videoController = VideoPlayerController.file(File(file.path));
                    await videoController.initialize();
                    controller.videoController = videoController;
                    controller.isVideoInitialized.value = true;
                  }
                  
                  print('🚀 Navigating to StoryScreen');
                  Get.back(); // Close camera
                  Get.back(); // Close media picker
                  Get.to(() => StoryScreen());
                }
              },
              multiple: (_) {},
            );
          } else if (event.status == MediaCaptureStatus.failure) {
            print('❌ Capture failed: ${event.exception}');
          }
        },
        theme: AwesomeTheme(
          bottomActionsBackgroundColor: Colors.black.withOpacity(0.5),
          buttonTheme: AwesomeButtonTheme(
            backgroundColor: Colors.white.withOpacity(0.2),
            iconSize: 32,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
