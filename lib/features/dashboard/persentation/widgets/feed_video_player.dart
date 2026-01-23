import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/network/app_urls.dart';

class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isPlay;

  const FeedVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.isPlay = false,
  }) : super(key: key);

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isMuted = false;
  final Key _visibilityKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Initialize controller but don't play yet unless visible
    _controller = VideoPlayerController.networkUrl(Uri.parse(AppUrls.getFullImageUrl(widget.videoUrl)))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.setLooping(true);
          // Initial play state will be handled by visibility detector or widget.isPlay
          if (widget.isPlay) {
            _controller.play();
          }
        });
      });
  }

  @override
  void didUpdateWidget(covariant FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlay != oldWidget.isPlay) {
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
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          
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
