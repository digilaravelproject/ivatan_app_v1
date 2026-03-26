import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import '../../dashboard/model/media_edit_models.dart';

class VideoEditScreen extends StatefulWidget {
  final File file;
  final bool isReel;
  const VideoEditScreen({super.key, required this.file, this.isReel = true});

  @override
  State<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends State<VideoEditScreen> {
  late VideoPlayerController _controller;
  
  // Trim State
  RxDouble startTime = 0.0.obs;
  RxDouble duration = 0.0.obs;
  double maxDuration = 0.0;
  
  // Filter State
  Rx<ColorFilter?> currentFilter = Rx<ColorFilter?>(null);
  
  // Text State
  final RxList<TextOverlay> textOverlays = <TextOverlay>[].obs;
  final RxBool showTextInput = false.obs;
  final TextEditingController textInputCtrl = TextEditingController();
  Color selectedTextColor = Colors.white;

  final RxBool showTrash = false.obs;
  final RxBool isOverTrash = false.obs;

  final List<Map<String, dynamic>> filters = [
    {'name': 'Origin', 'matrix': null, 'color': Colors.grey},
    {'name': 'Clarend', 'matrix': PresetFilters.clarendon, 'color': Colors.orange},
    {'name': 'Gingham', 'matrix': PresetFilters.gingham, 'color': Colors.blue},
    {'name': 'Moon', 'matrix': PresetFilters.moon, 'color': Colors.brown},
    {'name': 'Lark', 'matrix': PresetFilters.lark, 'color': Colors.green},
    {'name': 'Reyes', 'matrix': PresetFilters.reyes, 'color': Colors.teal},
    {'name': 'Juno', 'matrix': PresetFilters.juno, 'color': Colors.red},
    {'name': 'Slumber', 'matrix': PresetFilters.slumber, 'color': Colors.purple},
  ];

  final RxString activeTool = 'none'.obs; // 'none', 'trim', 'filter'

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        maxDuration = _controller.value.duration.inMilliseconds.toDouble();
        if (widget.isReel && maxDuration > 90000) {
          duration.value = 90000;
        } else {
          duration.value = maxDuration;
        }
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    // Return trim and filter data
    Get.back(result: {
      'startTime': startTime.value,
      'duration': duration.value,
      'filter': currentFilter.value,
      'textOverlays': textOverlays.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
        ? Stack(
            children: [
              // Main Video Preview
              Positioned.fill(
                child: Center(
                  child: Obx(() => ColorFiltered(
                    colorFilter: currentFilter.value ?? const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )),
                ),
              ),
              
              // Text Overlays
              _buildTextLayer(),

              // Top Controls
              Positioned(
                top: 50,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Get.back(),
                ),
              ),

              Positioned(
                top: 50,
                right: 20,
                child: Row(
                  children: [
                    _buildTopTool(Icons.text_fields, () => activeTool.value = 'text'),
                    const SizedBox(width: 15),
                    _buildTopTool(Icons.filter_vintage_outlined, () => activeTool.value = 'filter'),
                    // const SizedBox(width: 15),
                    // _buildTopTool(Icons.content_cut, () => activeTool.value = 'trim'),
                  ],
                ),
              ),

              Positioned(
                bottom: 40,
                right: 20,
                child: ElevatedButton(
                  onPressed: _onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ),

              // Bottom Panels
              _buildControlPanel(),

              // Trash Zone
              Positioned(
                bottom: 120,
                left: 0, right: 0,
                child: Obx(() => showTrash.value 
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isOverTrash.value ? Colors.red.withOpacity(0.8) : Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline, 
                        color: Colors.white, 
                        size: isOverTrash.value ? 40 : 30,
                      ),
                    ),
                  ) : const SizedBox.shrink()
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildTextLayer() {
    return Obx(() => Stack(
      children: textOverlays.map((t) {
        Offset initialFocalPoint = Offset.zero;
        Offset initialPosition = Offset.zero;
        double initialScale = 1.0;
        double initialRotation = 0.0;

        return Positioned(
          left: t.position.dx,
          top: t.position.dy,
          child: GestureDetector(
            onScaleStart: (details) {
              initialFocalPoint = details.focalPoint;
              initialPosition = t.position;
              initialScale = t.scale;
              initialRotation = t.rotation;
              showTrash.value = true;
            },
            onScaleUpdate: (details) {
              // Absolute displacement for stable movement
              t.position = initialPosition + (details.focalPoint - initialFocalPoint);
              
              if (details.scale != 1.0) {
                t.scale = (initialScale * details.scale).clamp(0.5, 5.0);
              }
              
              if (details.rotation != 0.0) {
                t.rotation = initialRotation + details.rotation;
              }
              
              // Check if over trash area
              double screenHeight = Get.height;
              isOverTrash.value = details.focalPoint.dy > screenHeight - 200;

              textOverlays.refresh();
            },
            onScaleEnd: (details) {
              if (isOverTrash.value) {
                textOverlays.remove(t);
              }
              showTrash.value = false;
              isOverTrash.value = false;
            },
            onDoubleTap: () => textOverlays.remove(t),
            child: Transform.rotate(
              angle: t.rotation,
              child: Transform.scale(
                scale: t.scale,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.transparent,
                  child: Text(t.text, 
                    style: TextStyle(
                      color: t.color, 
                      fontSize: 30, 
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(2, 2))]
                    )
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildTopTool(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Stack(
      children: [
        // Play/Pause button (Only show when NO tool is active)
        Positioned(
          bottom: 40,
          left: 20,
          child: Obx(() => activeTool.value == 'none' 
            ? _buildTopTool(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, () {
                setState(() {
                  if (_controller.value.isPlaying) _controller.pause();
                  else _controller.play();
                });
              })
            : const SizedBox.shrink()
          ),
        ),

        // Tool Panel (Trim, Filter, Text)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Obx(() {
            if (activeTool.value == 'none') return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activeTool.value.toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.blue),
                        onPressed: () => activeTool.value = 'none',
                      ),
                    ],
                  ),
                  if (activeTool.value == 'trim') _buildTrimmer(),
                  if (activeTool.value == 'filter') _buildFilterList(),
                  if (activeTool.value == 'text') _buildTextPrompt(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTrimmer() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.blue.withOpacity(0.2),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Obx(() => RangeSlider(
            values: RangeValues(
              startTime.value.clamp(0.0, maxDuration > 0 ? maxDuration : 1.0), 
              (startTime.value + duration.value).clamp(0.0, maxDuration > 0 ? maxDuration : 1.0)
            ),
            min: 0.0,
            max: maxDuration > 0 ? maxDuration : 1.0,
            onChanged: (values) {
              double start = values.start;
              double end = values.end;

              // Enforce 90s limit for Reels
              if (widget.isReel && (end - start) > 90000) {
                if (start != startTime.value) {
                  // User is moving the start handle
                  end = start + 90000;
                  if (end > maxDuration) {
                    end = maxDuration;
                    start = end - 90000;
                  }
                } else {
                  // User is moving the end handle
                  start = end - 90000;
                  if (start < 0) {
                    start = 0;
                    end = 90000;
                  }
                }
              }

              // Enforce 1s minimum duration
              if (end - start < 1000) {
                if (start != startTime.value) {
                  start = end - 1000;
                  if (start < 0) {
                    start = 0;
                    end = 1000;
                  }
                } else {
                  end = start + 1000;
                  if (end > maxDuration) {
                    end = maxDuration;
                    start = end - 1000;
                  }
                }
              }

              startTime.value = start;
              duration.value = end - start;
              _controller.seekTo(Duration(milliseconds: startTime.value.toInt()));
            },
          )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("0:00", style: TextStyle(color: Colors.white54, fontSize: 10)),
            Flexible(
              child: Obx(() => Text(
                "Selected: ${(duration.value / 1000).toStringAsFixed(1)}s ${widget.isReel ? '(Max 90s)' : ''}", 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
              )),
            ),
            Obx(() => Text(
               _formatDuration((maxDuration / 1000).toInt()), 
               style: const TextStyle(color: Colors.white54, fontSize: 10)
            )),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  Widget _buildFilterList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = currentFilter.value != null && filters.indexOf(f) != 0 || (currentFilter.value == null && filters.indexOf(f) == 0);

          return GestureDetector(
            onTap: () {
              if (f['matrix'] != null) {
                currentFilter.value = ColorFilter.matrix(f['matrix'] is ColorFilterGenerator ? f['matrix'].matrix : f['matrix']);
              } else {
                currentFilter.value = null;
              }
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: f['color'],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        if (isSelected) BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)
                      ]
                    ),
                    child: const Icon(Icons.filter_hdr, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(f['name'], style: TextStyle(color: isSelected ? Colors.blue : Colors.white, fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextPrompt() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textInputCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter text...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (textInputCtrl.text.isNotEmpty) {
                textOverlays.add(TextOverlay(text: textInputCtrl.text, color: Colors.white, position: const Offset(100, 200)));
                textInputCtrl.clear();
                activeTool.value = 'none';
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTextInput() {
    // Deprecated for direct inline input
  }
}
