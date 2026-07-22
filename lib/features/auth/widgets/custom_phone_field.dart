import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final RxString countryCode;
  final String labelText;
  final bool enabled;
  final Widget? suffixIcon;

  CustomPhoneField({
    super.key,
    required this.controller,
    required this.countryCode,
    this.labelText = 'Mobile Number',
    this.enabled = true,
    this.suffixIcon,
  });

  final List<Map<String, String>> countries = [
    {"name": "India", "code": "IN", "dialCode": "+91", "flag": "🇮🇳"},
    {"name": "Russia", "code": "RU", "dialCode": "+7", "flag": "🇷🇺"},
    {"name": "United States", "code": "US", "dialCode": "+1", "flag": "🇺🇸"},
  ];

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: suffixIcon,
        prefixIcon: InkWell(
          onTap: enabled ? () => _showCountryPicker(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final selected = countries.firstWhere((c) => c['dialCode'] == countryCode.value, orElse: () => countries[0]);
                  return Text(
                    "${selected['flag']} ${selected['dialCode']}",
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  );
                }),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: enabled ? Colors.grey : Colors.grey.shade400),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Country",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...countries.map((country) {
                return ListTile(
                  leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                  title: Text(country['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Text(country['dialCode']!, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  onTap: () {
                    countryCode.value = country['dialCode']!;
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
