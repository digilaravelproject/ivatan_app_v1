import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/dashboard/controller/create_story_controller.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final controller = Get.find<StoryController>();
  final GlobalKey _globalKey = GlobalKey(); // Key for capturing screenshot

  // Text overlay state
  final List<TextOverlay> textOverlays = [];
  final List<StickerOverlay> stickerOverlays = [];
  final List<DrawingStroke> drawingStrokes = [];
  List<Offset> currentStroke = [];

  bool showTextInput = false;
  bool showStickerPicker = false;
  bool isDrawing = false;

  // Drag & Delete state
  bool isDraggingItem = false;
  bool isOverDeleteZone = false;
  double _baseScale = 1.0;

  final TextEditingController textController = TextEditingController();
  Color selectedTextColor = AppColors.white;
  Color selectedDrawColor = Colors.red;
  String selectedTextStyle = 'Classic';
  String selectedTextShape = 'None';
  String selectedFont = 'Default';
  double drawStrokeWidth = 4.0;
  TextAlign selectedTextAlign = TextAlign.center;

  final List<Color> colors = [
    AppColors.white,
    AppColors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.pink,
    Colors.orange,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
  ];

  final List<String> textStyles = [
    'Classic',
    'Modern',
    'Bold',
    'Neon',
    'Shadow',
  ];

  final List<String> textShapes = ['None', 'Rectangle', 'Rounded', 'Circle'];

  final List<String> fonts = ['Default', 'Serif', 'Monospace', 'Cursive'];

  // Organized stickers by category
  final Map<String, List<String>> stickerCategories = {
    'Smileys': [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '😚',
      '😙',
      '🥲',
      '😋',
      '😛',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤭',
      '🤫',
      '🤔',
      '🤐',
      '🤨',
      '😐',
      '😑',
      '😶',
      '😏',
      '😒',
      '🙄',
      '😬',
      '🤥',
      '😌',
      '😔',
      '😪',
      '🤤',
      '😴',
      '😷',
      '🤒',
      '🤕',
      '🤢',
      '🤮',
      '🤧',
      '🥵',
      '🥶',
      '😎',
      '🤓',
      '🧐',
      '😕',
      '😟',
      '🙁',
      '☹️',
      '😮',
      '😯',
      '😲',
      '😳',
      '🥺',
      '😦',
      '😧',
      '😨',
      '😰',
      '😥',
      '😢',
      '😭',
      '😱',
      '😖',
      '😣',
      '😞',
      '😓',
      '😩',
      '😫',
      '🥱',
      '😤',
      '😡',
      '😠',
      '🤬',
      '😈',
      '👿',
      '💀',
      '☠️',
    ],
    'Hearts': [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💔',
      '❣️',
      '💕',
      '💞',
      '💓',
      '💗',
      '💖',
      '💘',
      '💝',
    ],
    'Hands': [
      '👍',
      '👎',
      '👊',
      '✊',
      '🤛',
      '🤜',
      '🤞',
      '✌️',
      '🤟',
      '🤘',
      '👌',
      '🤌',
      '🤏',
      '👈',
      '👉',
      '👆',
      '👇',
      '☝️',
      '👋',
      '🤚',
      '🖐️',
      '✋',
      '🖖',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🤝',
      '🙏',
    ],
    'Symbols': [
      '💯',
      '🔥',
      '✨',
      '⭐',
      '🌟',
      '💫',
      '⚡',
      '💥',
      '💢',
      '💨',
      '💦',
      '💤',
      '🎉',
      '🎊',
      '🎈',
      '🎁',
      '🏆',
      '🥇',
      '🥈',
      '🥉',
      '⚽',
      '🏀',
      '🏈',
      '⚾',
      '🎾',
      '🏐',
      '🏉',
      '🎱',
      '🏓',
      '🏸',
      '🏒',
      '🏑',
      '🥍',
      '🏏',
      '🥅',
      '⛳',
      '🏹',
      '🎣',
      '🤿',
      '🥊',
      '🥋',
      '🎽',
      '🛹',
      '🛼',
      '🛷',
      '⛸️',
      '🥌',
      '🎿',
      '⛷️',
      '🏂',
    ],
  };

  String selectedCategory = 'Smileys';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Stack(
              children: [
                // Media Preview
                Positioned.fill(
                  child: Obx(() {
                    if (controller.imageFile.value != null) {
                      return Image.file(
                        controller.imageFile.value!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }

                    if (controller.videoFile.value != null &&
                        controller.videoController != null &&
                        controller.videoController!.value.isInitialized) {
                      return SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller.videoController!.value.size.width,
                            height:
                                controller.videoController!.value.size.height,
                            child: VideoPlayer(controller.videoController!),
                          ),
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        "No media selected",
                        style: TextStyle(color: AppColors.white),
                      ),
                    );
                  }),
                ),

                // Drawing Layer
                if (drawingStrokes.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(painter: DrawingPainter(drawingStrokes)),
                  ),

                // Gesture detector for drawing
                if (isDrawing)
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          currentStroke = [details.localPosition];
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          currentStroke.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          drawingStrokes.add(
                            DrawingStroke(
                              points: List.from(currentStroke),
                              color: selectedDrawColor,
                              strokeWidth: drawStrokeWidth,
                            ),
                          );
                          currentStroke = [];
                        });
                      },
                      child:
                          currentStroke.isNotEmpty
                              ? CustomPaint(
                                painter: DrawingPainter([
                                  DrawingStroke(
                                    points: currentStroke,
                                    color: selectedDrawColor,
                                    strokeWidth: drawStrokeWidth,
                                  ),
                                ]),
                              )
                              : null,
                    ),
                  ),

                // Text Overlays
                ...textOverlays.map(
                  (overlay) => Positioned(
                    left: overlay.position.dx,
                    top: overlay.position.dy,
                    child: GestureDetector(
                      onScaleStart: (details) {
                        setState(() {
                          _baseScale = overlay.scale;
                          isDraggingItem = true;
                        });
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          overlay.position = Offset(
                            overlay.position.dx + details.focalPointDelta.dx,
                            overlay.position.dy + details.focalPointDelta.dy,
                          );

                          // Smooth scaling
                          overlay.scale = (_baseScale * details.scale).clamp(
                            0.5,
                            5.0,
                          );

                          // Check delete zone for text
                          final screenH = MediaQuery.of(context).size.height;
                          final screenW = MediaQuery.of(context).size.width;
                          final deleteZone = Offset(screenW / 2, screenH - 75);

                          if ((overlay.position +
                                      const Offset(50, 20) -
                                      deleteZone)
                                  .distance <
                              60) {
                            isOverDeleteZone = true;
                          } else {
                            isOverDeleteZone = false;
                          }
                        });
                      },
                      onScaleEnd: (details) {
                        setState(() {
                          isDraggingItem = false;
                          if (isOverDeleteZone) {
                            textOverlays.remove(overlay);
                            isOverDeleteZone = false;
                          }
                        });
                      },
                      onTap: () {
                        // Edit text on tap
                        setState(() {
                          textController.text = overlay.text;
                          selectedTextColor = overlay.color;
                          selectedTextStyle = overlay.style;
                          selectedTextShape = overlay.shape;
                          selectedFont = overlay.font;
                          showTextInput = true;
                          textOverlays.remove(overlay);
                        });
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Transform.scale(
                        scale: overlay.scale,
                        child: Container(
                          // Reduced invisible padding to prevent overlap blocking
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: _getTextShapeDecoration(overlay),
                            child: Text(
                              overlay.text,
                              style: _getTextStyle(overlay),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Sticker Overlays with pinch-to-zoom
                ...stickerOverlays.map(
                  (sticker) => Positioned(
                    left: sticker.position.dx,
                    top: sticker.position.dy,
                    child: GestureDetector(
                      onScaleStart: (details) {
                        setState(() {
                          _baseScale = sticker.scale;
                          isDraggingItem = true;
                        });
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          // Smooth scaling
                          sticker.scale = (_baseScale * details.scale).clamp(
                            0.5,
                            5.0,
                          );

                          // Movement
                          sticker.position = Offset(
                            sticker.position.dx + details.focalPointDelta.dx,
                            sticker.position.dy + details.focalPointDelta.dy,
                          );

                          // Check delete zone
                          final screenH = MediaQuery.of(context).size.height;
                          final screenW = MediaQuery.of(context).size.width;
                          final deleteZone = Offset(
                            screenW / 2,
                            screenH - 75,
                          ); // Center of trash bin

                          // Distance check (approx center of sticker)
                          final stickerCenter =
                              sticker.position + const Offset(32, 32);
                          if ((stickerCenter - deleteZone).distance < 60) {
                            isOverDeleteZone = true;
                          } else {
                            isOverDeleteZone = false;
                          }
                        });
                      },
                      onScaleEnd: (details) {
                        setState(() {
                          isDraggingItem = false;
                          if (isOverDeleteZone) {
                            stickerOverlays.remove(sticker);
                            isOverDeleteZone = false;
                          }
                        });
                      },
                      child: Transform.scale(
                        scale: sticker.scale,
                        child: Container(
                          decoration: BoxDecoration(
                            border:
                                isDraggingItem
                                    ? Border.all(
                                      color: AppColors.white.withOpacity(0.3),
                                      width: 1,
                                    )
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sticker.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // End of RepaintBoundary Content
              ],
            ),
          ),

          // Trash Bin (Delete Zone) - OUTSIDE RepaintBoundary to not capture it
          if (isDraggingItem)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isOverDeleteZone ? 60 : 50,
                  height: isOverDeleteZone ? 60 : 50,
                  decoration: BoxDecoration(
                    color:
                        isOverDeleteZone
                            ? Colors.red
                            : AppColors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      if (isOverDeleteZone)
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

          // Top Tools
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withOpacity(0.7),
                    AppColors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      _buildToolButton(
                        icon: Icons.close,
                        onTap: () => Get.back(),
                      ),

                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Crop/Rotate tool
                              // Crop/Rotate tool
                              _buildToolButton(
                                icon: Icons.crop_rotate,
                                onTap: () => controller.cropImage(),
                              ),

                              const SizedBox(width: 12),

                              // Text tool
                              _buildToolButton(
                                icon: Icons.text_fields,
                                onTap:
                                    () => setState(() {
                                      showTextInput = !showTextInput;
                                      showStickerPicker = false;
                                      isDrawing = false;
                                    }),
                                isActive: showTextInput,
                              ),

                              const SizedBox(width: 12),

                              // Sticker tool
                              _buildToolButton(
                                icon: Icons.emoji_emotions,
                                onTap:
                                    () => setState(() {
                                      showStickerPicker = !showStickerPicker;
                                      showTextInput = false;
                                      isDrawing = false;
                                    }),
                                isActive: showStickerPicker,
                              ),

                              const SizedBox(width: 12),

                              // Draw tool
                              _buildToolButton(
                                icon: Icons.brush,
                                onTap:
                                    () => setState(() {
                                      isDrawing = !isDrawing;
                                      showTextInput = false;
                                      showStickerPicker = false;
                                    }),
                                isActive: isDrawing,
                              ),

                              const SizedBox(width: 12),

                              // Undo drawing
                              if (drawingStrokes.isNotEmpty)
                                _buildToolButton(
                                  icon: Icons.undo,
                                  onTap:
                                      () => setState(() {
                                        if (drawingStrokes.isNotEmpty) {
                                          drawingStrokes.removeLast();
                                        }
                                      }),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Drawing Controls - 3 column grid
          if (isDrawing)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Color picker - 3 column grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: colors.length,
                      itemBuilder: (context, index) {
                        final color = colors[index];
                        return GestureDetector(
                          onTap:
                              () => setState(() => selectedDrawColor = color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    selectedDrawColor == color
                                        ? AppColors.white
                                        : AppColors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const Divider(color: AppColors.white, height: 20),

                    // Stroke width
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          [2.0, 4.0, 6.0, 8.0].map((width) {
                            return GestureDetector(
                              onTap:
                                  () => setState(() => drawStrokeWidth = width),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color:
                                      drawStrokeWidth == width
                                          ? AppColors.white
                                          : AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: width * 1.5,
                                    height: width * 1.5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // Enhanced Sticker Picker
          if (showStickerPicker)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.premiumGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Category tabs
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: stickerCategories.keys.length,
                          itemBuilder: (context, index) {
                            final category = stickerCategories.keys.elementAt(
                              index,
                            );
                            final isSelected = selectedCategory == category;

                            return GestureDetector(
                              onTap:
                                  () => setState(
                                    () => selectedCategory = category,
                                  ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : AppColors.premiumGold,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? AppColors.white
                                            : AppColors.white,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sticker grid
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemCount:
                              stickerCategories[selectedCategory]!.length,
                          itemBuilder: (context, index) {
                            final sticker =
                                stickerCategories[selectedCategory]![index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  stickerOverlays.add(
                                    StickerOverlay(
                                      emoji: sticker,
                                      position: Offset(
                                        MediaQuery.of(context).size.width / 2 -
                                            32,
                                        MediaQuery.of(context).size.height / 2 -
                                            32,
                                      ),
                                      scale: 1.0,
                                    ),
                                  );
                                  showStickerPicker = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.premiumGold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    sticker,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Instagram-like Text Input Overlay
          if (showTextInput)
            Positioned.fill(
              child: Container(
                color: AppColors.white.withOpacity(0.6),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Top Bar Area
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Alignment Toggle (Left)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Cycle alignment: Center -> Left -> Right -> Center
                                  if (selectedTextAlign == TextAlign.center) {
                                    selectedTextAlign = TextAlign.left;
                                  } else if (selectedTextAlign ==
                                      TextAlign.left) {
                                    selectedTextAlign = TextAlign.right;
                                  } else {
                                    selectedTextAlign = TextAlign.center;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  selectedTextAlign == TextAlign.center
                                      ? Icons.format_align_center
                                      : selectedTextAlign == TextAlign.left
                                      ? Icons.format_align_left
                                      : Icons.format_align_right,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                            ),

                            // Done Button (Right)
                            GestureDetector(
                              onTap: () {
                                if (textController.text.isNotEmpty) {
                                  setState(() {
                                    textOverlays.add(
                                      TextOverlay(
                                        text: textController.text,
                                        color: selectedTextColor,
                                        style:
                                            selectedTextStyle, // Use current style
                                        shape: selectedTextShape,
                                        font: selectedFont,
                                        scale: 1.0,
                                        position: Offset(
                                          MediaQuery.of(context).size.width /
                                                  2 -
                                              100, // Approximate center
                                          MediaQuery.of(context).size.height /
                                                  2 -
                                              50,
                                        ),
                                      ),
                                    );
                                    textController.clear();
                                    showTextInput = false;
                                  });
                                } else {
                                  setState(() => showTextInput = false);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.white.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Centered Text Field
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: textController,
                              autofocus: true,
                              maxLines: null,
                              textAlign: selectedTextAlign,
                              style: _getPreviewTextStyle(),
                              cursorColor: AppColors.white,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type...',
                                hintStyle: TextStyle(
                                  fontSize: 32,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Styling Tools
                      Positioned(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Font Selector (Bubbles)
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: fonts.length,
                                itemBuilder: (context, index) {
                                  final font = fonts[index];
                                  final isSelected = selectedFont == font;
                                  return GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedFont = font),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.white
                                                : AppColors.white.withOpacity(
                                                  0.4,
                                                ),
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                            isSelected
                                                ? null
                                                : Border.all(
                                                  color: AppColors.white,
                                                ),
                                      ),
                                      child: Text(
                                        font,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? AppColors.white
                                                  : AppColors.white,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Color Picker (Rings)
                            SizedBox(
                              height: 44,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: colors.length,
                                itemBuilder: (context, index) {
                                  final color = colors[index];
                                  final isSelected = selectedTextColor == color;
                                  return GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => selectedTextColor = color,
                                        ),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(
                                        2,
                                      ), // Space for border
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            isSelected
                                                ? Border.all(
                                                  color: AppColors.white,
                                                  width: 2,
                                                )
                                                : null,
                                      ),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child:
                                            isSelected
                                                ? const Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: AppColors.white,
                                                )
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bottom Function Row (Background & Style)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Background Toggle Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (selectedTextShape == 'None')
                                        selectedTextShape = 'Rounded';
                                      else if (selectedTextShape == 'Rounded')
                                        selectedTextShape = 'Circle';
                                      else
                                        selectedTextShape = 'None';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedTextShape != 'None'
                                              ? AppColors.white
                                              : AppColors.white.withOpacity(
                                                0.5,
                                              ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons
                                          .format_size, // Icon for background/style
                                      color:
                                          selectedTextShape != 'None'
                                              ? AppColors.white
                                              : AppColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Style Selector (Modern/Neon etc)
                                Flexible(
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children:
                                            textStyles.map((style) {
                                              final isSelected =
                                                  selectedTextStyle == style;
                                              return GestureDetector(
                                                onTap:
                                                    () => setState(
                                                      () =>
                                                          selectedTextStyle =
                                                              style,
                                                    ),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isSelected
                                                            ? AppColors.white
                                                            : AppColors
                                                                .transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    style,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          isSelected
                                                              ? AppColors.white
                                                              : AppColors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
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
              ),
            ),

          // Bottom Caption & Share
          if (!showTextInput && !showStickerPicker && !isDrawing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.black.withOpacity(0.7), AppColors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.white.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: controller.captionCtrl,
                                style: const TextStyle(color: AppColors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Add a caption...',
                                  hintStyle: TextStyle(color: AppColors.white),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Share Button (Icon only style for cleaner look)
                          Obx(() {
                            return controller.isLoading.value
                                ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                : InkWell(
                                  onTap: () => _captureAndShare(),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: AppColors.premiumGold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.send,
                                      color: AppColors.black,
                                      size: 24,
                                    ),
                                  ),
                                );
                          }),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // "Your Story" label below for clarity
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Your Story",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _captureAndShare() async {
    try {
      controller.isLoading.value = true;

      // 1. Capture the image from RepaintBoundary
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        controller.createStory(); // Fallback if capture fails
        return;
      }

      // Note: pixelRatio 3.0 for high quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file =
          await File(
            '${tempDir.path}/story_share_${DateTime.now().millisecondsSinceEpoch}.png',
          ).create();
      await file.writeAsBytes(pngBytes);

      // 3. Update controller with merged image
      // IMPORTANT: Only update imageFile, NOT originalImageFile, so further edits use the clean original
      // But for upload, we want the merged one.
      controller.imageFile.value = file;

      // 4. Upload
      await controller.createStory();
    } catch (e) {
      print("Capture Error: $e");
      controller.isLoading.value = false;
      Get.snackbar("Error", "Failed to process image");
    }
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // Reduced padding
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary : AppColors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border:
              isActive ? Border.all(color: AppColors.white, width: 2) : null,
        ),
        child: Icon(
          icon,
          color: AppColors.premiumGold,
          size: 20,
        ), // Reduced size
      ),
    );
  }

  BoxDecoration? _getTextShapeDecoration(TextOverlay overlay) {
    switch (overlay.shape) {
      case 'Rectangle':
        return BoxDecoration(
          color: overlay.color.withOpacity(0.3),
          border: Border.all(color: overlay.color, width: 2),
        );
      case 'Rounded':
        return BoxDecoration(
          color: overlay.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        );
      case 'Circle':
        return BoxDecoration(
          color: overlay.color.withOpacity(0.3),
          shape: BoxShape.circle,
        );
      default:
        return null;
    }
  }

  TextStyle _getTextStyle(TextOverlay overlay) {
    String? fontFamily;
    switch (overlay.font) {
      case 'Serif':
        fontFamily = 'serif';
        break;
      case 'Monospace':
        fontFamily = 'monospace';
        break;
      case 'Cursive':
        fontFamily = 'cursive';
        break;
      default:
        fontFamily = null;
    }

    switch (overlay.style) {
      case 'Modern':
        return TextStyle(
          color: overlay.color,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontFamily: fontFamily,
        );
      case 'Bold':
        return TextStyle(
          color: overlay.color,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        );
      case 'Neon':
        return TextStyle(
          color: overlay.color,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          shadows: [
            Shadow(color: overlay.color.withOpacity(0.8), blurRadius: 10),
            Shadow(color: overlay.color.withOpacity(0.6), blurRadius: 20),
          ],
        );
      case 'Shadow':
        return TextStyle(
          color: overlay.color,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.7),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        );
      default: // Classic
        return TextStyle(
          color: overlay.color,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        );
    }
  }

  TextStyle _getPreviewTextStyle() {
    String? fontFamily;
    switch (selectedFont) {
      case 'Serif':
        fontFamily = 'serif';
        break;
      case 'Monospace':
        fontFamily = 'monospace';
        break;
      case 'Cursive':
        fontFamily = 'cursive';
        break;
      default:
        fontFamily = null;
    }

    switch (selectedTextStyle) {
      case 'Modern':
        return TextStyle(
          color: selectedTextColor,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontFamily: fontFamily,
        );
      case 'Bold':
        return TextStyle(
          color: selectedTextColor,
          fontSize: 36,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        );
      case 'Neon':
        return TextStyle(
          color: selectedTextColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          shadows: [
            Shadow(color: selectedTextColor.withOpacity(0.8), blurRadius: 10),
            Shadow(color: selectedTextColor.withOpacity(0.6), blurRadius: 20),
          ],
        );
      case 'Shadow':
        return TextStyle(
          color: selectedTextColor,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.7),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        );
      default: // Classic
        return TextStyle(
          color: selectedTextColor,
          fontSize: 32,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: AppColors.white.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        );
    }
  }
}

class TextOverlay {
  String text;
  Color color;
  String style;
  String shape;
  String font;
  Offset position;
  double scale;

  TextOverlay({
    required this.text,
    required this.color,
    required this.style,
    required this.shape,
    required this.font,
    required this.position,
    this.scale = 1.0,
  });
}

class StickerOverlay {
  String emoji;
  Offset position;
  double scale;

  StickerOverlay({
    required this.emoji,
    required this.position,
    required this.scale,
  });
}

class DrawingStroke {
  List<Offset> points;
  Color color;
  double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      final paint =
          Paint()
            ..color = stroke.color
            ..strokeWidth = stroke.strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true; // Ideally compare stroke lists
}
