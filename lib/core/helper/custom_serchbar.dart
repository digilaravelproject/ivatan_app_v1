

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    Key? key,
    this.onTap,
    this.onChanged,
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
                color: AppColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.premiumGold, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: readOnly,
                      onTap: onTap,
                      onChanged: onChanged,
                      cursorColor: AppColors.premiumGold,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: AppColors.premiumGold,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color: AppColors.premiumGold,
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