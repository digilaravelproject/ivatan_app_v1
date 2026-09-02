import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:i_vatan_app/core/constants/app_assets.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

class LottieItem extends StatefulWidget {
  final String asset;
  final VoidCallback onCompleted;
  final EdgeInsets itemPadding;

  const LottieItem({
    Key? key,
    required this.asset,
    required this.onCompleted,
    required this.itemPadding,
  }) : super(key: key);

  @override
  _LottieItemState createState() => _LottieItemState();
}

class _LottieItemState extends State<LottieItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _playCount = 0; // how many times this animation has completed

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatus);
    _controller.dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _playCount++;
      if (_playCount < 2) {
        // Reset and play again.
        _controller.reset();
        _controller.forward();
      } else {
        // Two complete cycles reached, signal to parent.
        widget.onCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.itemPadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Lottie.asset(
          widget.asset,
          fit: BoxFit.cover,
          controller: _controller,
          onLoaded: (composition) {
            // Set the controller duration and add listener once.
            _controller.duration = composition.duration;
            _controller.reset();
            _controller.forward();
            _controller.addStatusListener(_handleStatus);
          },
        ),
      ),
    );
  }
}

class LottieSlider extends StatefulWidget {
  final List<String> lotties;
  final double viewPort;
  final MainAxisAlignment indicatorAlignment;
  final EdgeInsets itemPadding;
  final bool autoScroll;
  final bool isIndicatorVisible;

  const LottieSlider({
    Key? key,
    required this.lotties,
    this.indicatorAlignment = MainAxisAlignment.center,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.viewPort = 0.9,
    this.isIndicatorVisible = true,
    this.autoScroll = true, // Default is true
  }) : super(key: key);

  @override
  _LottieSliderState createState() => _LottieSliderState();
}

class _LottieSliderState extends State<LottieSlider> {
  late PageController _pageController;

  /// We keep track of the _currentPage as the index within the PageView,
  /// where index 0 is the duplicate of the last asset, indices 1..N are real,
  /// and index N+1 is the duplicate of the first asset.
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewPort,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Triggered once the visible Lottie animation has played twice.
  void _onLottieCompleted() {
    if (!widget.autoScroll) return;
    // Animate to the next page with ease-in/out.
    if (_currentPage < widget.lotties.length) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // If we are at the last real item, animate to duplicate and then jump.
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a list with duplicates for infinite scroll.
    List<String> assetsWithDuplicates = [
      widget.lotties.last,
      ...widget.lotties,
      widget.lotties.first,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The expanded PageView with Lottie animations.
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: assetsWithDuplicates.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Handle looping: jump without animation if at boundaries.
              if (index == 0) {
                Future.delayed(Duration(milliseconds: 300), () {
                  _pageController.jumpToPage(widget.lotties.length);
                });
              } else if (index == widget.lotties.length + 1) {
                Future.delayed(Duration(milliseconds: 300), () {
                  _pageController.jumpToPage(1);
                });
              }
            },
            itemBuilder: (context, index) {
              // For each page, decide whether to attach the autoPlay/repeat logic.
              // We want only the currently visible (i.e. active) real slide to auto-play.
              final asset = assetsWithDuplicates[index];

              // Only attach auto-play logic on the “real” page that is currently visible.
              // The duplicates or non-visible pages simply show the asset.
              if (widget.autoScroll &&
                  index == _currentPage &&
                  index != 0 &&
                  index != widget.lotties.length + 1) {
                return LottieItem(
                  asset: asset,
                  itemPadding: widget.itemPadding,
                  onCompleted: _onLottieCompleted,
                );
              } else {
                // For non-active pages, simply display the Lottie animation without auto-play.
                return Padding(
                  padding: widget.itemPadding,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Lottie.asset(
                      asset,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        SizedBox(height: 10),
        // Page indicator
        Visibility(
          visible: widget.isIndicatorVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: widget.indicatorAlignment,
              children: [
                for (int i = 0; i < widget.lotties.length; i++)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == i + 1 ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: _currentPage == i + 1
                          ? LinearGradient(colors: [Colors.blue, Colors.green])
                          : LinearGradient(colors: [AppColors.premiumGold, AppColors.premiumGold]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImageSlider extends StatefulWidget {
  final List<String> images;
  final double viewPort;
  final MainAxisAlignment indicatorAlignment;
  final EdgeInsets itemPadding;
  final bool autoScroll;
  final bool isIndicatorVisible;
  final double borderRadius;

  const ImageSlider({
    super.key,
    required this.images,
    this.indicatorAlignment = MainAxisAlignment.center,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.viewPort = 0.9,
    this.isIndicatorVisible = true,
    this.borderRadius = 5,
    this.autoScroll = true, // Default is true
  });

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late PageController _pageController;
  int _currentPage = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewPort,
    );
    if (widget.autoScroll) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < widget.images.length + 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _currentPage = 1;
        _pageController.jumpToPage(
          _currentPage,
        ); // Jump to the first duplicated page without animation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> imagesWithDuplicates = [
      widget.images.last,
      ...widget.images,
      widget.images.first,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: imagesWithDuplicates.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: widget.itemPadding,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Image.network(
                    imagesWithDuplicates[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red
                        ),
                        child: Text("Image not found")
                        // Image.asset(
                        //   AppAssets.imgNotFound,
                        //   fit: BoxFit.cover,
                        //   height: 50,
                        //   width: 50,
                        // ),
                      );
                    },
                  ),
                ),
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              if (index == imagesWithDuplicates.length - 1) {
                Future.delayed(Duration(milliseconds: 300), () {
                  _pageController.jumpToPage(1);
                });
              } else if (index == 0) {
                Future.delayed(Duration(milliseconds: 300), () {
                  _pageController.jumpToPage(widget.images.length);
                });
              }
            },
          ),
        ),
        SizedBox(height: 10),
        Visibility(
          visible: widget.isIndicatorVisible,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: widget.indicatorAlignment,
              children: [
                for (int i = 0; i < widget.images.length; i++)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    width: _currentPage == i + 1 ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == i + 1
                          ? AppColors.primaryDark
                          : AppColors.neutralGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfiniteScrollImages extends StatefulWidget {
  final List<String> imageUrls;
  final void Function(int actualIndex)? onImageVisible;

  const InfiniteScrollImages({
    super.key,
    required this.imageUrls,
    this.onImageVisible,
  });

  @override
  State<InfiniteScrollImages> createState() => _InfiniteScrollImagesState();
}

class _InfiniteScrollImagesState extends State<InfiniteScrollImages>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late Ticker _ticker;

  final double itemWidth = 50 + 24; // 50px image + 24px gap

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _ticker = createTicker(_scroll)..start();
  }

  void _scroll(Duration elapsed) {
    if (_scrollController.hasClients) {
      double newOffset = _scrollController.offset + 0.7;

      double resetPoint = _scrollController.position.maxScrollExtent -
          (itemWidth * widget.imageUrls.length);

      if (newOffset > resetPoint) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(newOffset);
      }
    }
  }

  int getActualImageIndex(int position) {
    return position % widget.imageUrls.length;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Repeat images to simulate infinite scroll
    final repeatedImages = List.generate(
      100,
      (i) => widget.imageUrls[i % widget.imageUrls.length],
    );

    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: repeatedImages.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              final actualIndex = getActualImageIndex(index);
              SchedulerBinding.instance.addPostFrameCallback((_) {
                widget.onImageVisible?.call(actualIndex);
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Container(
                padding: EdgeInsets.all(6),
                child: Image.network(
                  repeatedImages[index],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.premiumGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
