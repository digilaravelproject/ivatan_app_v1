import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '${currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final imageUrl = AppUrls.getFullImageUrl(widget.images[index]);
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: AppColors.premiumGold),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              );
            },
          );
        },
        itemCount: widget.images.length,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
        ),
        pageController: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
