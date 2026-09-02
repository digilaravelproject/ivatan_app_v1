import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';

class AvatarCustomizerScreen extends StatelessWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the FluttermojiController before building widgets that depend on it
    Get.put(FluttermojiController());

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text("Customize Avatar", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FluttermojiSaveWidget(
              onTap: () async {
                print("🎨 Saving Fluttermoji...");
                // Fluttermoji saves to internal storage automatically.
                // We extract the SVG string to convert it to PNG for the server.
                try {

                  // In v1.0.2, we use encodeMySVGtoString and decodeFluttermojifromString
                  String? encoded = await FluttermojiFunctions().encodeMySVGtoString();
                  if (encoded != null) {
                    String svgString = FluttermojiFunctions().decodeFluttermojifromString(encoded);
                    print("🎨 SVG decoded, length: ${svgString.length}");
                    
                    File? rasterFile = await _convertSvgToImage(svgString);
                    if (rasterFile != null) {
                      print("✅ Avatar rasterized to: ${rasterFile.path}");
                      Get.back(result: rasterFile);
                    } else {
                      print("❌ Avatar conversion failed");
                      Get.snackbar("Error", "Could not generate avatar image", backgroundColor: Colors.red, colorText: AppColors.white);
                    }
                  }
                } catch (e) {
                  print("❌ Error exporting Fluttermoji: $e");
                  Get.snackbar("Error", "Failed to save avatar", backgroundColor: Colors.red, colorText: AppColors.white);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Save",
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.white, AppColors.premiumGold.withOpacity(0.1)],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: FluttermojiCircleAvatar(
                      radius: 100,
                      backgroundColor: AppColors.premiumGold.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.white.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: FluttermojiCustomizer(
                    scaffoldHeight: 400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File?> _convertSvgToImage(String svgString) async {
    try {
      // 1. Parse SVG
      final loader = SvgStringLoader(svgString);
      final PictureInfo pictureInfo = await vg.loadPicture(loader, null);

      // 2. Determine size and scale
      const double targetSize = 512;
      
      // Create a recorder to draw the scaled picture
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Calculate scale to fit
      final double scale = targetSize / 280; // Fluttermoji default viewBox is roughly 280x280
      
      // Shift slightly if needed, but centering is better
      canvas.scale(scale);
      canvas.drawPicture(pictureInfo.picture);
      
      final scaledPicture = recorder.endRecording();
      final ui.Image image = await scaledPicture.toImage(targetSize.toInt(), targetSize.toInt());
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 3. Save to temp file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (e) {
      print("SVG to Image conversion error: $e");
      return null;
    }
  }
}
