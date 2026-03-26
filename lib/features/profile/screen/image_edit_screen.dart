import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/helper/custom_snack_bar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import '../../dashboard/model/media_edit_models.dart';
import '../controller/profile_controller.dart';

class ImageEditScreen extends StatefulWidget {
  final File file;
  final String userName;

  const ImageEditScreen({super.key, required this.file, required this.userName});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  final GlobalKey _globalKey = GlobalKey();
  late File currentFile;
  late final ProfileController controller;

  // Editing State
  final RxList<TextOverlay> textOverlays = <TextOverlay>[].obs;
  final RxList<StickerOverlay> stickerOverlays = <StickerOverlay>[].obs;
  final RxList<DrawingStroke> strokes = <DrawingStroke>[].obs;

  final RxBool isDrawing = false.obs;
  final RxBool showTextInput = false.obs;
  final RxBool showStickerPicker = false.obs;

  Color selectedColor = Colors.white;
  double strokeWidth = 5.0;

  final RxBool showTrash = false.obs;
  final RxBool isOverTrash = false.obs;

  // Text Editor State
  final TextEditingController textInputCtrl = TextEditingController();
  Color selectedTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    currentFile = widget.file;
    controller = Get.find<ProfileController>(tag: widget.userName);
  }

  Future<void> _captureAndDone() async {
    try {
      if (textOverlays.isEmpty && stickerOverlays.isEmpty && strokes.isEmpty) {
        Get.back(result: currentFile);
        return;
      }

      RenderRepaintBoundary? boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.back(result: currentFile);
        return;
      }

      // Use a lower pixel ratio to avoid OutOfDeviceMemory on some devices
      ui.Image image = await boundary.toImage(pixelRatio: 2.0); 
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/image_edit_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      Get.back(result: file);
    } catch (e) {
      CustomSnackBar.showError(message: "Failed to save edits");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _captureAndDone,
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    currentFile,
                    fit: BoxFit.contain,
                  ),
                  _buildLayeredCanvas(),
                ],
              ),
            ),
          ),
          
          // Toolbars
          _buildToolbars(),
          
          // Trash Zone
          Obx(() => showTrash.value 
            ? Positioned(
                bottom: 50,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOverTrash.value ? Colors.red.withOpacity(0.8) : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline, 
                      color: Colors.white, 
                      size: isOverTrash.value ? 35 : 28,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()),

          // Overlay Inputs (Text/Sticker)
          Obx(() => showTextInput.value ? _buildTextInputField() : const SizedBox.shrink()),
          Obx(() => showStickerPicker.value ? _buildStickerPicker() : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildToolbars() {
    return Positioned(
      top: 10,
      right: 15,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.crop_rotate, color: Colors.white),
              onPressed: () async {
                final croppedFile = await ImageCropper().cropImage(
                  sourcePath: currentFile.path,
                  compressQuality: 90,
                  uiSettings: [
                    AndroidUiSettings(
                      toolbarTitle: 'Crop Image',
                      toolbarColor: Colors.black,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false,
                    ),
                    IOSUiSettings(title: 'Crop Image'),
                  ],
                );
                if (croppedFile != null) {
                  setState(() => currentFile = File(croppedFile.path));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.white),
              onPressed: () => showTextInput.value = true,
            ),
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white),
              onPressed: () => showStickerPicker.value = true,
            ),
            Obx(() => IconButton(
              icon: Icon(Icons.brush, color: isDrawing.value ? Colors.blue : Colors.white),
              onPressed: () => isDrawing.value = !isDrawing.value,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLayeredCanvas() {
    return Stack(
      children: [
        // Drawing
        Obx(() => CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(strokes.toList()),
        )),
        
        // Stickers
        Obx(() => Stack(
          children: stickerOverlays.map((s) => _buildOverlayItem(s)).toList(),
        )),
        
        // Text
        Obx(() => Stack(
          children: textOverlays.map((t) => _buildOverlayItem(t)).toList(),
        )),
        
        // Interaction Layer for Drawing
        Obx(() => isDrawing.value 
          ? GestureDetector(
              onPanStart: (details) {
                strokes.add(DrawingStroke(
                  points: [details.localPosition],
                  color: selectedColor,
                  strokeWidth: strokeWidth,
                ));
              },
              onPanUpdate: (details) {
                if (strokes.isNotEmpty) {
                  strokes.last.points.add(details.localPosition);
                  strokes.refresh();
                }
              },
            )
          : const SizedBox.shrink()
        ),
      ],
    );
  }

  Widget _buildOverlayItem(dynamic overlay) {
    Offset initialFocalPoint = Offset.zero;
    Offset initialPosition = Offset.zero;
    double initialScale = 1.0;
    double initialRotation = 0.0;

    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          initialFocalPoint = details.focalPoint;
          initialPosition = overlay.position;
          initialScale = overlay.scale;
          initialRotation = overlay.rotation;
          showTrash.value = true;
        },
        onScaleUpdate: (details) {
          overlay.position = initialPosition + (details.focalPoint - initialFocalPoint);
          
          if (details.scale != 1.0) {
            overlay.scale = (initialScale * details.scale).clamp(0.5, 5.0);
          }
          
          if (details.rotation != 0.0) {
            overlay.rotation = initialRotation + details.rotation;
          }

          // Check if over trash area (bottom 150px)
          double screenHeight = Get.height;
          isOverTrash.value = details.focalPoint.dy > screenHeight - 150;
          
          if (overlay is TextOverlay) textOverlays.refresh();
          if (overlay is StickerOverlay) stickerOverlays.refresh();
        },
        onScaleEnd: (details) {
          if (isOverTrash.value) {
            if (overlay is TextOverlay) textOverlays.remove(overlay);
            if (overlay is StickerOverlay) stickerOverlays.remove(overlay);
          }
          showTrash.value = false;
          isOverTrash.value = false;
        },
        onDoubleTap: () {
          if (overlay is TextOverlay) textOverlays.remove(overlay);
          if (overlay is StickerOverlay) stickerOverlays.remove(overlay);
        },
        child: Transform.rotate(
          angle: overlay.rotation,
          child: Transform.scale(
            scale: overlay.scale,
            child: Container(
              padding: const EdgeInsets.all(15), 
              color: Colors.transparent,
              child: overlay is TextOverlay 
                ? Text(overlay.text, 
                    style: TextStyle(
                      color: overlay.color, 
                      fontSize: 30, 
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(2, 2))]
                    )
                  )
                : Text(overlay.emoji, style: const TextStyle(fontSize: 50)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputField() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textInputCtrl,
              autofocus: true,
              style: TextStyle(color: selectedTextColor, fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Type something...", hintStyle: TextStyle(color: Colors.white24)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Colors.white, Colors.red, Colors.green, Colors.blue, Colors.yellow].map((c) => GestureDetector(
                onTap: () => setState(() => selectedTextColor = c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: selectedTextColor == c ? Colors.white : Colors.transparent, width: 2)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (textInputCtrl.text.isNotEmpty) {
                  textOverlays.add(TextOverlay(text: textInputCtrl.text, color: selectedTextColor, position: const Offset(100, 200)));
                  textInputCtrl.clear();
                }
                showTextInput.value = false;
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerPicker() {
    final emojis = ["😂", "❤️", "🔥", "🙌", "✨", "🌟", "💯", "😎", "🌈", "🦋"];
    return Container(
      color: Colors.black54,
      child: Center(
        child: Wrap(
          spacing: 15, runSpacing: 15,
          children: emojis.map((e) => GestureDetector(
            onTap: () {
              stickerOverlays.add(StickerOverlay(emoji: e, position: const Offset(150, 300)));
              showStickerPicker.value = false;
            },
            child: Text(e, style: const TextStyle(fontSize: 40)),
          )).toList(),
        ),
      ),
    );
  }
}
