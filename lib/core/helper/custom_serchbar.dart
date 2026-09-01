

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomSearchBar({
    Key? key,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: readOnly,
                      onTap: onTap,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.search,
                    color: AppColors.lightTextSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // const SizedBox(width: 10),
          // Icon(Icons.filter_list, color: AppColors.black, size: 28),
        ],
      ),
    );
  }
}