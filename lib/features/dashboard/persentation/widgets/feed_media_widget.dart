import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../model/post_model.dart';
import 'feed_video_player.dart';

class FeedMediaWidget extends StatefulWidget {
  final List<PostMedia> media;
  final String type; // "image" or "video"
  final VoidCallback onDoubleTap;

  const FeedMediaWidget({
    Key? key,
    required this.media,
    required this.type,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  State<FeedMediaWidget> createState() => _FeedMediaWidgetState();
}

class _FeedMediaWidgetState extends State<FeedMediaWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showHeartAnimation = false;

  void _handleDoubleTap() {
    widget.onDoubleTap();
    setState(() {
      _showHeartAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showHeartAnimation = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Content
          _buildContent(),

          // Heart Animation Overlay
          if (_showHeartAnimation)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.2),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                );
              },
              onEnd: () {
                // Fade out could be handled here or simpler just hide
              },
            ),

          // Carousel Indicators (Dots)
          if (widget.media.length > 1)
            Positioned(
              bottom: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.media.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentIndex == index ? 8 : 6,
                    height: _currentIndex == index ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Multiple Items Indicator (Top Right)
          if (widget.media.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_currentIndex + 1}/${widget.media.length}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Single Video
    if (widget.type == "video") {
      return FeedVideoPlayer(videoUrl: widget.media.first.url);
    }

    // Images (Single or Multiple)
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 500,
        minHeight: 300,
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.media.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: widget.media[index].url,
            fit: BoxFit.cover,
            placeholder: (context, url) => const _ShimmerPlaceholder(),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder({Key? key}) : super(key: key);

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [
                0.1,
                0.3,
                0.4,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}
