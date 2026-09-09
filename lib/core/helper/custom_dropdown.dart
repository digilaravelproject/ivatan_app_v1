import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class CustomSearchableDropdown extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> items;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const CustomSearchableDropdown({
    super.key,
    required this.label,
    required this.controller,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSearchBottomSheet(context),
      child: AbsorbPointer( // Prevents keyboard from opening
        child: TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: AppColors.premiumGold),
            floatingLabelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.premiumGold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.premiumGold.withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    final RxList<String> filteredItems = RxList<String>(items);
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.premiumGold),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                   // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.premiumGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Header
                  Text(
                    "Select $label",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                      hintText: "Search $label...",
                      hintStyle: TextStyle(color: AppColors.premiumGold),
                      prefixIcon: Icon(Icons.search, color: AppColors.premiumGold),
                      filled: true,
                      fillColor: AppColors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.premiumGold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        filteredItems.value = items;
                      } else {
                        filteredItems.value = items
                            .where((item) =>
                                item.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // List
                  Expanded(
                    child: Obx(() {
                      if (filteredItems.isEmpty) {
                        return Center(
                          child: Text(
                            "No results found",
                            style: TextStyle(color: AppColors.premiumGold),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: filteredItems.length,
                        separatorBuilder: (c, i) => Divider(height: 1, color: AppColors.premiumGold.withOpacity(0.3)),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = item == controller.text;
                          
                          return InkWell(
                            onTap: () {
                              controller.text = item;
                              if (onChanged != null) {
                                onChanged!(item);
                              }
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected ? AppColors.primary : AppColors.white,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    const Icon(Icons.check, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
              )
            );
          },
        );
      },
    );
  }
}
