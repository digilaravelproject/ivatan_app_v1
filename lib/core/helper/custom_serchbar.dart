

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
              height: 40, // Reduced height for compact look
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Flat Grey
                borderRadius: BorderRadius.circular(12),
                // Removed BoxShadow
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.lightTextSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      readOnly: readOnly,
                      onTap: onTap,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 10)
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
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