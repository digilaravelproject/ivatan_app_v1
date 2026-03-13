import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../controller/create_service_controller.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';

class CreateServiceScreen extends StatelessWidget {
  CreateServiceScreen({super.key});

  final CreateServiceController controller =
  Get.put(CreateServiceController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Service",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Image Pickers
            const Text("Cover Image *",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _buildCoverImagePicker(),

            const SizedBox(height: 20),
            const Text("Additional Images",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _buildAdditionalImagesPicker(),

            const SizedBox(height: 25),

            /// 🔹 Service Name
            const Text("Service Name *",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: nameController,
              hint: "Enter service name",
            ),

            SizedBox(height: 20),

            /// 🔹 Description
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: descriptionController,
              hint: "Enter description",
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            /// 🔹 Pricing
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Price *",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: priceController,
                        hint: "Enter price",
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Discount Price",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: discountPriceController,
                        hint: "Enter discount",
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // const SizedBox(height: 20),
            //
            // /// 🔹 Stock
            // const Text("Stock Quantity",
            //     style: TextStyle(fontWeight: FontWeight.w600)),
            // const SizedBox(height: 8),
            // _buildTextField(
            //   controller: stockController,
            //   hint: "Enter stock quantity",
            //   keyboardType: TextInputType.number,
            // ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                  controller.submitService(
                    title: nameController.text,
                    description: descriptionController.text,
                    price: priceController.text,
                    discountPrice: discountPriceController.text,
                    stock: stockController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                  "Create Service",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImagePicker() {
    return Obx(() {
      return GestureDetector(
        onTap: controller.pickCoverImage,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black26),
            color: Colors.grey.shade100,
          ),
          child: controller.coverImage.value == null
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text("Select Cover Image"),
            ],
          )
              : Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  controller.coverImage.value!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: controller.removeCoverImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAdditionalImagesPicker() {
    return Obx(() {
      return Column(
        children: [
          if (controller.additionalImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.additionalImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.additionalImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeAdditionalImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (controller.additionalImages.isNotEmpty) const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.pickAdditionalImages,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black26, style: BorderStyle.solid),
                color: Colors.grey.shade50,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Add More Images", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 🔹 Common TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
