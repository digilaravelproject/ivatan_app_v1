import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:iconly/iconly.dart';
import 'package:video_player/video_player.dart';
import '../../../core/helper/custom_image_view.dart';
import '../../../core/utils/app_icons.dart';
import '../../../../core/network/app_urls.dart';
import '../../dashboard/controller/follow_controller.dart';
import '../../dashboard/controller/homeController.dart';
import '../../dashboard/controller/navigationController.dart';
import '../../dashboard/persentation/home_screen.dart';
import '../../dashboard/persentation/widgets/feed_media_widget.dart';
import '../../post/presentation/image_post_screen.dart';
import '../controller/short_play_controller.dart';
import '../model/reel_model.dart';
import 'package:share_plus/share_plus.dart';
typedef LikeCallback = void Function(String reelId);
typedef CommentCallback = void Function(String reelId);
typedef ShareCallback = void Function(String reelId);
typedef FollowCallback = void Function(String authorId);
typedef IndexChangedCallback = void Function(int index);

class ReelsView extends StatefulWidget {
  final List<ReelModel> reels;
  final LikeCallback? onLike;
  final CommentCallback? onComment;
  final ShareCallback? onShare;
  final FollowCallback? onFollow;
  final IndexChangedCallback? onIndexChanged;
  final Widget? likeIcon;
  final Widget? unlikeIcon;
  final Widget? commentIcon;
  final Widget? shareIcon;
  final Widget? followText;
  final Widget? verifiedBadge;
  final Color? progressBarColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showProgress;
  final bool loop;
  final bool showVerifiedTick;
  final bool showAuthor;
  final bool showLikes;
  final bool showComments;
  final bool showShares;
  final bool showViews;
  final bool showTags;
  final bool showDescription;
  final bool showTitle;
  final bool showUploadDate;
  final bool showFollowButton;
  final bool showMoreOptions;
  final bool showSettings;
  final bool showVolumeControl;
  final bool showPlayPause;
  final bool showBuffering;
  final bool showReplay;
  final bool showGradient;
  final bool showLikeAnimation;
  final bool allowSwipeToDismiss;
  final bool allowDoubleTapToLike;
  final bool allowTapToPause;
  final int preloadCount;

  final List<Widget>? rightActionButtons;
  final List<Widget>? leftActionButtons;

  final Widget Function(BuildContext context, String reelId)?
  settingsDialogBuilder;
  final Widget Function(BuildContext context, String reelId)?
  shareDialogBuilder;
  final Widget Function(BuildContext context, String reelId)?
  commentSectionBuilder;
  final Widget Function(BuildContext context, String reelId)?
  moreOptionsDialogBuilder;

  const ReelsView({
    super.key,
    required this.reels,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onFollow,
    this.onIndexChanged,
    this.likeIcon,
    this.unlikeIcon,
    this.commentIcon,
    this.shareIcon,
    this.followText,
    this.verifiedBadge,
    this.progressBarColor,
    this.loadingWidget,
    this.errorWidget,
    this.showProgress = true,
    this.loop = true,
    this.showVerifiedTick = true,
    this.showAuthor = true,
    this.showLikes = true,
    this.showComments = true,
    this.showShares = true,
    this.showViews = true,
    this.showTags = true,
    this.showDescription = true,
    this.showTitle = true,
    this.showUploadDate = true,
    this.showFollowButton = true,
    this.showMoreOptions = true,
    this.showSettings = true,
    this.showVolumeControl = true,
    this.showPlayPause = true,
    this.showBuffering = true,
    this.showReplay = true,
    this.showGradient = true,
    this.showLikeAnimation = true,
    this.allowSwipeToDismiss = true,
    this.allowDoubleTapToLike = true,
    this.allowTapToPause = true,
    this.preloadCount = 2,
    this.rightActionButtons,
    this.leftActionButtons,
    this.settingsDialogBuilder,
    this.shareDialogBuilder,
    this.commentSectionBuilder,
    this.moreOptionsDialogBuilder,
  });

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<VideoPlayerController?> _videoControllers;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  final ValueNotifier<bool> _isLiked = ValueNotifier(false);

  // Volume Animation
  late AnimationController _volumeAnimationController;
  late Animation<double> _volumeAnimation;
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  int _currentPage = 0;

  double _dragDistance = 0.0;
  late AnimationController _dismissAnimationController;
  late Animation<double> _dismissAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
      overlays: [],
    );

    // ✅ Status bar color transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _pageController = PageController(initialPage: _currentPage);
    _videoControllers = List<VideoPlayerController?>.filled(
      widget.reels.length,
      null,
    );

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _likeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_likeAnimationController);

    // Volume Init
    _volumeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _volumeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _volumeAnimationController, curve: Curves.easeOut));

    _dismissAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dismissAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_dismissAnimationController)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_dismissAnimationController);
    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.black.withValues(alpha: 0.5),
    ).animate(_dismissAnimationController);

    _initializeControllersForPage(_currentPage);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    _pageController.dispose();
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    _likeAnimationController.dispose();
    _volumeAnimationController.dispose();
    _dismissAnimationController.dispose();
    _isLiked.dispose();
    _isMuted.dispose();
    super.dispose();
  }

  void _toggleSound() {
    if (_videoControllers[_currentPage] == null) return;
    
    final controller = _videoControllers[_currentPage]!;
    if (controller.value.volume > 0) {
      controller.setVolume(0.0);
      _isMuted.value = true;
    } else {
      controller.setVolume(1.0);
      _isMuted.value = false;
    }

    _volumeAnimationController.reset();
    _volumeAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
             if(mounted) _volumeAnimationController.reverse();
        });
    });
  }

  void _initializeControllersForPage(int page) {
    if (_videoControllers[_currentPage] != null &&
        _videoControllers[_currentPage]!.value.isInitialized) {
      _videoControllers[_currentPage]!.pause();
    }

    _currentPage = page;
    widget.onIndexChanged?.call(page);

    for (int i = 0; i < _videoControllers.length; i++) {
      if (i < page - widget.preloadCount || i > page + widget.preloadCount) {
        if (_videoControllers[i] != null) {
          _videoControllers[i]!.dispose();
          _videoControllers[i] = null;
        }
      }
    }

    for (
      int i = page - widget.preloadCount;
      i <= page + widget.preloadCount;
      i++
    ) {
      if (i >= 0 && i < widget.reels.length) {
        if (_videoControllers[i] == null) {
          _videoControllers[i] = _createVideoPlayerController(widget.reels[i]);
          _videoControllers[i]!.initialize().then((_) {
            _videoControllers[i]!.setLooping(widget.loop);
            if (i == _currentPage) {
              _videoControllers[i]!.play();
            }
            if (mounted) {
              setState(() {});
            }
          });
        }
      }
    }

    if (_videoControllers[page] != null &&
        _videoControllers[page]!.value.isInitialized) {
      _videoControllers[page]!.play();
    }
  }

  void _onPageChanged(int index) {
    _initializeControllersForPage(index);
  }

  /*  VideoPlayerController _createVideoPlayerController(ReelModel reel) {
    // if (reel.videoType == VideoType.m3u8) {
    //   return VideoPlayerController.networkUrl(
    //     Uri.parse(reel.url),
    //     viewType: VideoViewType.platformView,
    //     videoPlayerOptions: VideoPlayerOptions(
    //       mixWithOthers: true,
    //     ),
    //   );
    // } else {
      return VideoPlayerController.networkUrl(
        Uri.parse(reel.media[0].url),
        viewType: VideoViewType.platformView,
      );
   // }
  }*/

  VideoPlayerController _createVideoPlayerController(ReelModel reel) {
    if (reel.media.isEmpty) {
      debugPrint("⚠️ Skipping reel with empty media: ${reel.id}");
      // Dummy controller (never plays)
      return VideoPlayerController.asset("assets/empty.mp4");
    }

    return VideoPlayerController.networkUrl(
      Uri.parse(reel.media.first.url),
      viewType: VideoViewType.platformView,
    );
  }

  void _toggleLike() {
    _isLiked.value = !_isLiked.value;
    // widget.onLike?.call(widget.reels[_currentPage].id ?? "");
    if (_isLiked.value && widget.showLikeAnimation) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
  }

  void _followAuthor() {
    // widget.onFollow?.call(widget.reels[_currentPage].author.id);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.allowSwipeToDismiss) return;
    setState(() {
      _dragDistance += details.delta.dy;
      _dismissAnimationController.value = (_dragDistance / context.size!.height)
          .abs()
          .clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.allowSwipeToDismiss) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() > 500 || _dragDistance.abs() > 100) {
      _dismissAnimationController.forward();
    } else {
      _dismissAnimationController.reverse().then((_) {
        setState(() {
          _dragDistance = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dismissAnimationController,
      builder: (context, child) {
        return Container(
          color: _backgroundAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _dragDistance),
              child: Opacity(opacity: _dismissAnimation.value, child: child),
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: GestureDetector(
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: PageView.builder(
            controller: _pageController,
            physics: const PageScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: widget.reels.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final controller = _videoControllers[index];
              if (controller == null) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.reels[index].user.avatar,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              widget.loadingWidget ??
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              widget.errorWidget ?? const Icon(Icons.error),
                    ),
                    widget.loadingWidget ??
                        const Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              return VideoReel(
                index: index,
                pageController: _pageController,
                reel: widget.reels[index],
                controller: controller,
                likeAnimation: _likeAnimation,
                isLiked: _isLiked,
                onLike: _toggleLike,
                onFollow: _followAuthor,
                // Volume Props
                isMuted: _isMuted,
                onToggleSound: _toggleSound,
                volumeAnimation: _volumeAnimation,
                
                allowDoubleTapToLike: widget.allowDoubleTapToLike,
                allowTapToPause: widget.allowTapToPause,
                commentIcon: widget.commentIcon,
                errorWidget: widget.errorWidget,
                followText: widget.followText,
                leftActionButtons: widget.leftActionButtons,
                likeIcon: widget.likeIcon,
                loadingWidget: widget.loadingWidget,
                progressBarColor: widget.progressBarColor,
                rightActionButtons: widget.rightActionButtons,
                shareIcon: widget.shareIcon,
                showAuthor: widget.showAuthor,
                showBuffering: widget.showBuffering,
                showComments: widget.showComments,
                showDescription: widget.showDescription,
                showFollowButton: widget.showFollowButton,
                showGradient: widget.showGradient,
                showLikeAnimation: widget.showLikeAnimation,
                showLikes: widget.showLikes,
                showMoreOptions: widget.showMoreOptions,
                showPlayPause: widget.showPlayPause,
                showProgress: widget.showProgress,
                showReplay: widget.showReplay,
                showSettings: widget.showSettings,
                showShares: widget.showShares,
                showTags: widget.showTags,
                showTitle: widget.showTitle,
                showUploadDate: widget.showUploadDate,
                showVerifiedTick: widget.showVerifiedTick,
                showVolumeControl: widget.showVolumeControl,
                unlikeIcon: widget.unlikeIcon,
                verifiedBadge: widget.verifiedBadge,
                settingsDialogBuilder: widget.settingsDialogBuilder,
                shareDialogBuilder: widget.shareDialogBuilder,
                moreOptionsDialogBuilder: widget.moreOptionsDialogBuilder,
                onComment: () {},
                onShare: () {},
              );
            },
          ),
        ),
      ),
    );
  }
}

class VideoReel extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController controller;
  final PageController pageController;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final Animation<double> likeAnimation;
  final ValueNotifier<bool> isLiked;
  
  // New Volume Props
  final ValueNotifier<bool> isMuted;
  final VoidCallback onToggleSound;
  final Animation<double> volumeAnimation;

  final bool allowDoubleTapToLike;
  final bool allowTapToPause;
  final Widget? likeIcon;
  final Widget? unlikeIcon;
  final Widget? commentIcon;
  final Widget? shareIcon;
  final Widget? followText;
  final Widget? verifiedBadge;
  final Color? progressBarColor;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final bool showProgress;
  final bool showVerifiedTick;
  final bool showAuthor;
  final bool showLikes;
  final bool showComments;
  final bool showShares;
  final bool showTags;
  final bool showDescription;
  final bool showTitle;
  final bool showUploadDate;
  final bool showFollowButton;
  final bool showMoreOptions;
  final bool showSettings;
  final bool showVolumeControl;
  final bool showPlayPause;
  final bool showBuffering;
  final bool showReplay;
  final int index;
  final bool showGradient;
  final bool showLikeAnimation;
  final List<Widget>? rightActionButtons;
  final List<Widget>? leftActionButtons;
  final Widget Function(BuildContext context, String reelId)?
  settingsDialogBuilder;
  final Widget Function(BuildContext context, String reelId)?
  shareDialogBuilder;
  final Widget Function(BuildContext context, String reelId)?
  moreOptionsDialogBuilder;

  const VideoReel({
    super.key,
    required this.reel,
    required this.controller,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.likeAnimation,
    required this.isLiked,
    // Required Volume Props
    required this.isMuted,
    required this.onToggleSound,
    required this.volumeAnimation,

    required this.allowDoubleTapToLike,
    required this.allowTapToPause,
    required this.pageController,
    required this.index,
    this.likeIcon,
    this.unlikeIcon,
    this.commentIcon,
    this.shareIcon,
    this.followText,
    this.verifiedBadge,
    this.progressBarColor,
    this.loadingWidget,
    this.errorWidget,
    required this.showProgress,
    required this.showVerifiedTick,
    required this.showAuthor,
    required this.showLikes,
    required this.showComments,
    required this.showShares,
    required this.showTags,
    required this.showDescription,
    required this.showTitle,
    required this.showUploadDate,
    required this.showFollowButton,
    required this.showMoreOptions,
    required this.showSettings,
    required this.showVolumeControl,
    required this.showPlayPause,
    required this.showBuffering,
    required this.showReplay,
    required this.showGradient,
    required this.showLikeAnimation,
    this.rightActionButtons,
    this.leftActionButtons,
    this.settingsDialogBuilder,
    this.shareDialogBuilder,
    this.moreOptionsDialogBuilder,
  });

  @override
  Widget build(BuildContext context) {
  //  final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final bottomNavHeight = kBottomNavigationBarHeight;
    return GestureDetector(
      onDoubleTap: allowDoubleTapToLike ? onLike : null,
      onLongPressStart: (_) => controller.pause(),
      onLongPressEnd: (_) => controller.play(),
      onTap: onToggleSound, // Use the callback
      child: Container(
        // margin: EdgeInsets.only(
        //   //top: appBarHeight,
        //   bottom: bottomNavHeight,
        // ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomReelPlayer(
              controller: controller,
              //  thumbnailUrl: reel.media[index].url,
              thumbnailUrl:
                  reel.media.isNotEmpty ? reel.media.first.thumbnail : "",
              loadingWidget: loadingWidget,
              errorWidget: errorWidget,
            ),
            if (showPlayPause) VideoOverlay(controller: controller),
            if (showLikeAnimation) LikeAnimation(likeAnimation: likeAnimation),
            // Volume Animation Overlay
            ValueListenableBuilder<bool>(
              valueListenable: isMuted,
              builder: (context, muted, child) {
                return VolumeAnimation(volumeAnimation: volumeAnimation, isMuted: muted);
              },
            ),
            if (showGradient) const VideoGradient(),
            ScreenOptions(
              item: reel,
              pageViewController: pageController,
              index: index,
            ),
            if (showProgress)
              VideoProgressBar(
                videoController: controller,
                color: progressBarColor,
                modal: reel,
              ),
          ],
        ),
      ),
    );
  }
}

class CustomReelPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final String thumbnailUrl;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CustomReelPlayer({
    super.key,
    required this.controller,
    required this.thumbnailUrl,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Background for letterboxing if needed
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          if (value.isInitialized) {
             // 1. Calculate aspect ratios
            final videoAspectRatio = value.size.width / value.size.height;
            // Use MediaQuery to get screen aspect ratio, but here we are in a PageView likely full screen
            // For Reels, we generally want cover. 
            // However, creating a truly custom layout:
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover, // FORCE FILL SCREEN like TikTok
                child: SizedBox(
                   width: value.size.width,
                   height: value.size.height,
                   child: VideoPlayer(controller),
                ),
              ),
            );
          } else if (value.hasError) {
             return errorWidget ??
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 40),
                    const SizedBox(height: 8),
                    const Text('Failed to load', style: TextStyle(color: Colors.white)),
                  ],
                ),
              );
          } else {
            // Loading State: Show Thumbnail
            return SizedBox.expand(
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    loadingWidget ??
                    const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            );
          }
        },
      ),
    );
  }
}

class VideoOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        return Stack(
          children: [
            if (value.isBuffering)
              const Center(child: CircularProgressIndicator()),
            if (value.position == value.duration && !value.isPlaying)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (!value.isPlaying && value.position != value.duration)
              const Center(
                child: Icon(Icons.play_arrow, size: 80, color: Colors.white),
              ),
          ],
        );
      },
    );
  }
}

class LikeAnimation extends StatelessWidget {
  final Animation<double> likeAnimation;

  const LikeAnimation({super.key, required this.likeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: likeAnimation,
      child: const Center(
        child: Icon(Icons.favorite, size: 80, color: Colors.red), // Increased size
      ),
    );
  }
}

class VolumeAnimation extends StatelessWidget {
  final Animation<double> volumeAnimation;
  final bool isMuted;

  const VolumeAnimation({super.key, required this.volumeAnimation, required this.isMuted});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: volumeAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class VideoGradient extends StatelessWidget {
  const VideoGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: .3),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }
}

class ScreenOptions extends GetWidget<ShortPlayController> {
  final ReelModel item;
  final PageController pageViewController;
  final int index;

  ScreenOptions({
    super.key,
    required this.item,
    required this.pageViewController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_buildBottomSection(context).marginOnly(bottom: 30)],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildProfileAndDescription()),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildProfileAndDescription() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(),
          if (item.caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                item.caption!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return InkWell(
      onTap: () {
        final nav = Get.find<DashboardController>();
        nav.changeIndex(4, username: item.user.username);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: item.user.avatar.isNotEmpty
                ? CustomImageView(
                    url: AppUrls.getFullImageUrl(item.user.avatar),
                    height: 38,
                    width: 38,
                    radius: BorderRadius.circular(19),
                  )
                : const CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 24, color: Colors.white),
                  ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    item.user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 4),
                      ],
                    ),
                  ),
                   const SizedBox(width: 8),
                   // Simple Follow Button (Visual)
                   Obx(() {
                     final homeController = Get.find<HomeController>();
                     final isFollowing = homeController.followController.isUserFollowing(item.user.id, initialValue: item.isFollowing).value;
                     
                     // Hide follow button if it's my own reel
                     if (item.isMine) return const SizedBox.shrink();

                     return GestureDetector(
                       onTap: () => homeController.toggleFollowForPostUser(item.user.id),
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                         decoration: BoxDecoration(
                           color: isFollowing ? Colors.white.withOpacity(0.2) : Colors.transparent,
                           border: Border.all(color: Colors.white, width: 1),
                           borderRadius: BorderRadius.circular(6),
                         ),
                         child: Text(
                           isFollowing ? "Following" : "Follow",
                           style: const TextStyle(
                             color: Colors.white,
                             fontSize: 10,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     );
                   }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // _buildIconButton(
        //   icon: const Icon(IconlyLight.send, color: Colors.white, size: 30),
        //   label: "Share",
        //   onPressed: () {
        //     //controller.shareReels(context, item),
        //   },
        // ),
        const SizedBox(height: 16),
        Obx(
          () => GestureDetector(
            onTap: () {
              controller.updateShortVideoLike(item.id, index);
            },
            child: Column(
              children: [
                CustomIcon(
                  svgString:
                      controller.isLikedMap[index]?.value == true
                          ? AppIcons.ic_heart_solid
                          : AppIcons.ic_heart_outline,
                  color:
                      controller.isLikedMap[index]?.value == true
                          ? Colors.red
                          : Colors.white,
                  removeColor: controller.isLikedMap[index]?.value == true,
                  size: 30,
                ),
                Text(
                  controller.likeCounts[index]?.value.toString() ?? "0",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        Obx(
          () => _buildIconButton(
            icon:
            //Image.asset(AppAssets.imgShare),
            CustomIcon(
              svgString: AppIcons.ic_comments,
              color: Colors.white,
              size: 30,
              removeColor: false,
            ),
            label: controller.commentCounts[index]?.value.toString() ?? "0",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CommentsBottomSheet(postId: item.id),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
        _buildIconButton(
          icon: CustomIcon(
            svgString: AppIcons.ic_share,
            color: Colors.white,
            size: 30,
            removeColor: false,
          ),
          label: "Share",
          onPressed: () {
            // Create shareable link
            final String reelUrl = "https://ivatan.in/post/${item.id}";
            final String shareText = "${item.caption ?? 'Check out this reel!'}\n\n$reelUrl";
            
            // Use share_plus to share
            Share.share(shareText);
          },
        ),

      ],
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    String? label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.translucent,
          child: Container(
            // Removed background circle for cleaner look
            padding: const EdgeInsets.all(10), // slight padding for touch area
            decoration: BoxDecoration(
               shape: BoxShape.circle,
               // color: Colors.black.withOpacity(0.1), // Optional: very subtle
            ),
            child: icon,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 4),
              ],
            ),
          ),
        ],
      ],
    );
  }

  _showFeedBackBottomSheet(ReelModel item) {
    // controller.feedBackController.text = item.feedBack.value;
    Get.bottomSheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 12,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              side: BorderSide(color: AppColors.white, width: 1),
            ),
            icon: Icon(Icons.close, color: AppColors.white),
          ),
          // AddFeedbackBtmSheet(
          //   item: item,
          // ),
        ],
      ),
      isScrollControlled: true,
      persistent: true,
    );
  }

  /*
  _showLectureBottomSheet(ReelModel item, BuildContext context) {
    Get.bottomSheet(
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 12,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            style: IconButton.styleFrom(
              backgroundColor: darkBackGround,
              side: BorderSide(
                color: secondaryColor,
                width: 1,
              ),
            ),
            icon: Icon(Icons.close, color: secondaryColor),
          ),
          Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 12.0,
                bottom: MediaQuery.of(context).padding.bottom + 12,
                right: 12,
                left: 12,
              ),
              child: Column(
                spacing: 8,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Text(
                    "Lectures",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: controller.reelsList.length,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final modal = controller.reelsList[index];
                      final currentIndexOfVideo =
                          controller.selectedPosition.value;
                      return GestureDetector(
                        onTap: () {
                          if (index != currentIndexOfVideo) {
                            pageViewController.jumpToPage(index);
                            Get.back();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: index == currentIndexOfVideo
                                ? Border.all(color: primaryColor, width: 2)
                                : Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    modal.profileUrl,
                                    height: 40,
                                    width: 40,
                                    errorBuilder: (_, __, ___) {
                                      return Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey.shade200,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                modal.videoTitle,
                                maxLines: 1,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: textColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
*/
}

class VideoProgressBar extends GetWidget<ShortPlayController> {
  final VideoPlayerController videoController;
  final Color? color;
  final ReelModel modal;

  /// Flag to make sure API call happens only once
  bool _hasCalledApi = false;

  VideoProgressBar({
    super.key,
    required this.videoController,
    required this.modal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ValueListenableBuilder(
        valueListenable: videoController,
        builder: (context, value, child) {
          // View Count Logic preserved
          if (value.isInitialized && !_hasCalledApi) {
             final halfDuration = value.duration.inSeconds / 2;
             if (value.position.inSeconds >= halfDuration) {
               _hasCalledApi = true;
             }
          }
          return SizedBox(
            height: 4, // Very thin container
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: SliderComponentShape.noThumb, // Provide no thumb options
                overlayShape: SliderComponentShape.noOverlay,
                trackHeight: 2.0,
                activeTrackColor: Colors.black, // Changed from Cyan to Black
                inactiveTrackColor: Colors.black.withOpacity(0.3),
                trackShape: const RectangularSliderTrackShape(), // Full width
              ),
              child: Slider(
                value: value.position.inSeconds.toDouble().clamp(0.0, value.duration.inSeconds.toDouble()),
                min: 0.0,
                max: value.duration.inSeconds.toDouble() > 0 ? value.duration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  videoController.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onSettings;
  final VoidCallback onMore;
  final bool showVolumeControl;
  final bool showSettings;
  final bool showMoreOptions;

  const VideoControls({
    super.key,
    required this.controller,
    required this.onSettings,
    required this.onMore,
    required this.showVolumeControl,
    required this.showSettings,
    required this.showMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: Row(
        children: [
          if (showVolumeControl)
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return IconButton(
                  icon: Icon(
                    value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.setVolume(value.volume == 0 ? 1.0 : 0.0);
                  },
                );
              },
            ),
          if (showSettings)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: onSettings,
            ),
          if (showMoreOptions)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: onMore,
            ),
        ],
      ),
    );
  }
}

class CustomIcon extends StatelessWidget {
  final double size;
  final Color color;
  final String svgString;
  final bool removeColor;

  final BoxFit fit;

  const CustomIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    required this.svgString,
    this.removeColor = true,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgString,
      height: size,
      width: size,
      fit: fit,
      color: removeColor ? null : color,
    );
  }
}
