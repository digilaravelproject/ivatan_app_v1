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
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            floatingLabelStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
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
            fillColor: Colors.grey.shade50,
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
      backgroundColor: Colors.white,
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
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
              child: Column(
                children: [
                   // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search $label...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
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
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: filteredItems.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
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
                                      color: isSelected ? AppColors.primary : Colors.black87,
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
            );
          },
        );
      },
    );
  }
}
