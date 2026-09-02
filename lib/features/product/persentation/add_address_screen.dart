import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/custom_buttons.dart';
import 'controller/add_address_controller.dart';

class AddAddressScreen extends GetWidget<AddAddressController> {
  const AddAddressScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    //final AddAddressController controller = Get.put(AddAddressController());
    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Address',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Title
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your delivery address',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.premiumGold,
                ),
              ),
              const SizedBox(height: 30),

              // Form Fields
              _buildTextField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: controller.phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: controller.addressLine1Controller,
                label: 'Address Line 1',
                hint: 'House/Flat No., Building Name',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: controller.addressLine2Controller,
                label: 'Address Line 2',
                hint: 'Street, Area (Optional)',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              // City and State Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: controller.cityController,
                      label: 'City',
                      hint: 'Enter city',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: controller.stateController,
                      label: 'State',
                      hint: 'Enter state',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Zip and Country Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: controller.pinCodeController,
                      label: 'PIN Code',
                      hint: 'Enter PIN code',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Country',
                      value: controller.selectedCountry.value,
                      items: ['India', 'USA', 'UK', 'Canada'],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setCountry(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Address Type Selection
             /* const Text(
                'Address Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildAddressTypeChip('Home', Icons.home),
                  const SizedBox(width: 16),
                  _buildAddressTypeChip('Office', Icons.work),
                  const SizedBox(width: 16),
                  _buildAddressTypeChip('Other', Icons.location_on),
                ],
              ),
              const SizedBox(height: 30),*/

              // Save as Default Checkbox
              // Row(
              //   children: [
              //     SizedBox(
              //       height: 24,
              //       width: 24,
              //       child: Checkbox(
              //         value: true,
              //         onChanged: (value) {},
              //         activeColor: AppColors.white,
              //         side: const BorderSide(color: AppColors.premiumGold),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(4),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     const Text(
              //       'Set as default address',
              //       style: TextStyle(
              //         fontSize: 14,
              //         color: AppColors.white,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 30),

              // Save Address Button
              Obx(() => CustomButton(
                backgroundColor: AppColors.primary,
                borderRadius: 16,
                title: controller.isLoading.value ? "Saving..." : "Save Address",
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.saveAddress();
                      },
              )),

              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGold.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.premiumGold, fontSize: 14),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.premiumGold, size: 20)
                  : null,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.premiumGold),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.premiumGold),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.white, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.premiumGold),
            color: AppColors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.premiumGold),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, color: AppColors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeChip(String label, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedType.value == label;

        return Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? AppColors.white : AppColors.premiumGold,
            ),
            color:
            isSelected ? AppColors.white.withOpacity(0.05) : AppColors.transparent,
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                controller.selectType(label);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color:
                    isSelected ? AppColors.white : AppColors.premiumGold,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.premiumGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}