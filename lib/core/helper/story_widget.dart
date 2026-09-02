import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StoryWidgets {
  /// ADD STORY BUTTON
  static Widget addStory() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'New',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// STORY ITEM (NAME + IMAGE)
  static Widget storyItem({
    required String name,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: (imageUrl == null || imageUrl.isEmpty)
                ? _placeholder()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _placeholder(),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.premiumGold,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.premiumGold,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo_library_outlined,
          color: AppColors.premiumGold,
          size: 24,
        ),
      ),
    );
  }
}
