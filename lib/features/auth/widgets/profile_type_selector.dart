import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../data/model/res/profile_type_model.dart';

class ProfileTypeSelector extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<ProfileType> profileTypes;
  final Function(ProfileType, String) onSelected;
  final String? Function(String?)? validator;
  final bool enabled;

  const ProfileTypeSelector({
    super.key,
    required this.label,
    required this.controller,
    required this.profileTypes,
    required this.onSelected,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => _showProfileTypeBottomSheet(context) : null,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: AppColors.premiumGold),
            floatingLabelStyle: const TextStyle(
              color: AppColors.premiumGold,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon:
                enabled
                    ? const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.premiumGold,
                    )
                    : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.black,
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'personal':
        return Icons.person_outline_rounded;
      case 'employer':
        return Icons.business_center_outlined;
      case 'seller':
        return Icons.storefront_outlined;
      case 'music':
        return Icons.library_music_outlined;
      case 'creator':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.star_border_rounded;
    }
  }

  void _showProfileTypeBottomSheet(BuildContext context) {
    // Track which type is currently expanded (any type with subtypes)
    String? expandedType =
        profileTypes
            .firstWhereOrNull(
              (t) =>
                  t.sellerTypes.isNotEmpty &&
                  controller.text.startsWith(t.label),
            )
            ?.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      Text(
                        "Select $label",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: profileTypes.length,
                          separatorBuilder:
                              (c, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final pType = profileTypes[index];
                            // Any profile type that has subtypes from the API gets expanded
                            final hasSubTypes = pType.sellerTypes.isNotEmpty;
                            final isSelected = controller.text.startsWith(
                              pType.label,
                            );
                            final isExpanded = expandedType == pType.type;

                            if (hasSubTypes) {
                              return _buildProfileTypeCard(
                                pType: pType,
                                isSelected: isSelected,
                                isSellerExpanded: isExpanded,
                                onTap: () {
                                  setModalState(() {
                                    expandedType =
                                        isExpanded ? null : pType.type;
                                  });
                                },
                                child:
                                    isExpanded
                                        ? _buildSellerSubtypes(
                                          pType,
                                          isSelected,
                                          context,
                                        )
                                        : null,
                              );
                            }

                            return _buildProfileTypeCard(
                              pType: pType,
                              isSelected: isSelected,
                              isSellerExpanded: false,
                              onTap: () {
                                onSelected(pType, '');
                                Navigator.pop(context);
                              },
                              child: null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTypeCard({
    required ProfileType pType,
    required bool isSelected,
    required bool isSellerExpanded,
    required VoidCallback onTap,
    required Widget? child,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.premiumGold.withOpacity(0.15)
                    : AppColors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.premiumGold : AppColors.premiumGold.withOpacity(0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.premiumGold
                                : AppColors.premiumGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(pType.type),
                        color:
                            isSelected
                                ? AppColors.black
                                : AppColors.premiumGold,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pType.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pType.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.premiumGold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Show expand arrow for any type that has subtypes from the API
                  if (pType.sellerTypes.isNotEmpty)
                    Icon(
                      isSellerExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.premiumGold,
                    )
                  else if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                ],
              ),
              if (child != null) child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerSubtypes(
    ProfileType pType,
    bool isSelected,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.premiumGold),
      ),
      child: Column(
        children:
            pType.sellerTypes.map((subType) {
              final subTypeLabel = subType.capitalizeFirst ?? subType;
              final isSubSelected =
                  isSelected &&
                  controller.text.toLowerCase().contains(subType.toLowerCase());

              return Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () {
                    onSelected(pType, subType);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSubSelected
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSubSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color:
                              isSubSelected
                                  ? AppColors.primary
                                  : AppColors.premiumGold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          subTypeLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSubSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                            color:
                                isSubSelected
                                    ? AppColors.primary
                                    : AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        if (isSubSelected)
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
