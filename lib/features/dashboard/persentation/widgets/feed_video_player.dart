import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/network/app_urls.dart';
import '../../../../db/shared_pref_manager.dart';

class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlay;
  final ValueChanged<double>? onRatioLoaded;
  final BoxFit fit;

  const FeedVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.isPlay = false,
    this.onRatioLoaded,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isMuted = true;
  final Key _visibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(AppUrls.getFullImageUrl(widget.videoUrl)),
      httpHeaders: {
        "Authorization": "Bearer ${SharedPrefManager().token ?? AppUrls.defaultApiKey}"
      },
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.setLooping(true);
            _controller.setVolume(_isMuted ? 0.0 : 1.0);
            if (widget.isPlay) {
              _controller.play();
            }
          });
          if (widget.onRatioLoaded != null) {
            widget.onRatioLoaded!(_controller.value.aspectRatio);
          }
        }
      });
  }

  @override
  void didUpdateWidget(covariant FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      setState(() {
        _initialized = false;
      });
      _controller.dispose();
      _initializeController();
    } else if (widget.isPlay != oldWidget.isPlay) {
      if (widget.isPlay) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black12,
        height: 300, // Default height to avoid layout shift
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      );
    }

    Widget videoWidget = AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );

    if (widget.fit == BoxFit.cover) {
      videoWidget = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width > 0 ? _controller.value.size.width : 16,
            height: _controller.value.size.height > 0 ? _controller.value.size.height : 9,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    }

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (visibilityInfo) {
        if (!_initialized) return; // Safety check

        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        debugPrint("Video Visibility: ${widget.videoUrl} -> $visiblePercentage%");

        if (visiblePercentage > 60) { // Play if more than 60% visible
          if (!_controller.value.isPlaying) {
             _controller.play();
          }
        } else {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          videoWidget,
          
          // Mute Button (Bottom Right)
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
