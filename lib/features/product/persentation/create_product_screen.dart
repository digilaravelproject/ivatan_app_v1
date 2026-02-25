import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

class CreateProductController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var selectedImages = <File>[].obs;
  var isLoading = false.obs;

  Future<void> pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((image) => File(image.path)));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void createProduct({
    required String name,
    required String description,
    required String price,
    required String discountPrice,
    required String category,
    required String stock,
  }) {
    if (name.isEmpty || description.isEmpty || price.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedImages.isEmpty) {
      Get.snackbar(
        "Error",
        "Please add at least one product image",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    // TODO: API call to create product
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.back();
      Get.snackbar(
        "Success",
        "Product Created Successfully",
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }
}

class CreateProductScreen extends StatelessWidget {
  CreateProductScreen({super.key});

  final CreateProductController controller = Get.put(CreateProductController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountPriceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.black),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Product Images
              const Text(
                "Product Images *",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _buildImagePicker(),

              const SizedBox(height: 25),

              /// 🔹 Product Name
              const Text(
                "Product Name *",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: nameController,
                hint: "Enter product name",
              ),

              const SizedBox(height: 20),

              /// 🔹 Description
              const Text(
                "Description *",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: descriptionController,
                hint: "Enter product description",
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              /// 🔹 Category
              const Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: categoryController,
                hint: "e.g., Electronics, Fashion, Food",
              ),

              const SizedBox(height: 20),

              /// 🔹 Price & Discount Price Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price *",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: priceController,
                          hint: "₹ 0.00",
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
                        const Text(
                          "Discount Price",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: discountPriceController,
                          hint: "₹ 0.00",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Stock
              const Text(
                "Stock Quantity",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: stockController,
                hint: "Enter available quantity",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 40),

              /// 🔹 Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.createProduct(
                      name: nameController.text,
                      description: descriptionController.text,
                      price: priceController.text,
                      discountPrice: discountPriceController.text,
                      category: categoryController.text,
                      stock: stockController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Add Product",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  /// 🔹 Image Picker Widget
  Widget _buildImagePicker() {
    return Obx(() {
      return Column(
        children: [
          // Selected Images Grid
          if (controller.selectedImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.selectedImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          if (controller.selectedImages.isNotEmpty) const SizedBox(height: 10),

          // Add Image Button
          GestureDetector(
            onTap: controller.pickImagesFromGallery,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.lightBorder, width: 2),
                color: AppColors.lightBackground,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.selectedImages.isEmpty
                        ? "Tap to add images"
                        : "Add more images",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
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
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
      ),
    );
  }
}
