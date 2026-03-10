import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/network/api_services.dart';

class CreateProductController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiServices apiServices = Get.find<ApiServices>();

  var coverImage = Rx<File?>(null);
  var additionalImages = <File>[].obs;
  var isLoading = false.obs;

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      coverImage.value = File(image.path);
    }
  }

  void removeCoverImage() {
    coverImage.value = null;
  }

  Future<void> pickAdditionalImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      additionalImages.addAll(images.map((img) => File(img.path)));
    }
  }

  void removeAdditionalImage(int index) {
    if (index >= 0 && index < additionalImages.length) {
      additionalImages.removeAt(index);
    }
  }

  Future<void> createProduct({
    required String title,
    required String description,
    required String price,
    required String discountPrice,
    required String stock,
  }) async {
    // Validation 1: Check required fields
    if (title.isEmpty || description.isEmpty || price.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validation 2: Check cover image
    if (coverImage.value == null) {
      Get.snackbar(
        "Error",
        "Please select a cover image",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validation 3: Check price is valid number
    double? priceValue = double.tryParse(price);
    if (priceValue == null || priceValue <= 0) {
      Get.snackbar(
        "Error",
        "Please enter a valid price (must be greater than 0)",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validation 4: Check discount price is less than regular price
    if (discountPrice.isNotEmpty) {
      double? discountValue = double.tryParse(discountPrice);
      if (discountValue == null) {
        Get.snackbar(
          "Error",
          "Please enter a valid discount price",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (discountValue >= priceValue) {
        Get.snackbar(
          "Error",
          "Discount price must be less than regular price",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Validation 5: Check image file types
    List<String> validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    
    // Check cover image
    String coverImageExt = coverImage.value!.path.split('.').last.toLowerCase();
    if (!validExtensions.contains(coverImageExt)) {
      Get.snackbar(
        "Error",
        "Cover image must be jpeg, jpg, png, or webp format",
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check additional images
    for (var img in additionalImages) {
      String imgExt = img.path.split('.').last.toLowerCase();
      if (!validExtensions.contains(imgExt)) {
        Get.snackbar(
          "Error",
          "All images must be jpeg, jpg, png, or webp format",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isLoading.value = true;

    try {
      Map<String, dynamic> body = {
        "title": title,
        "description": description,
        "price": priceValue,
        "discount_price": discountPrice.isNotEmpty ? double.parse(discountPrice) : null,
        "stock": stock.isNotEmpty ? int.parse(stock) : 0,
        "cover_image": coverImage.value,
      };

      // Add additional images with indexed keys
      for (int i = 0; i < additionalImages.length; i++) {
        body["images[$i]"] = additionalImages[i];
      }

      final response = await apiServices.callPost(
        AppUrls.sellerProducts,
        data: body,
        isFormData: true,
      );

      if (response != null && response['success'] == true) {
        // Store API response data
        final productData = response['data'];
        print("Product Created Successfully!");
        print("Product ID: ${productData['id']}");
        print("Product UUID: ${productData['uuid']}");
        print("Product Slug: ${productData['slug']}");
        print("Status: ${productData['status']}");
        print("Created At: ${productData['created_at']}");

        Get.back();
        Get.snackbar(
          "Success",
          response['message'] ?? "Product created successfully",
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error",
          response?['message'] ?? "Failed to create product",
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class CreateProductScreen extends StatelessWidget {
  CreateProductScreen({super.key});

  final CreateProductController controller = Get.put(CreateProductController());

  final TextEditingController titleController = TextEditingController();
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
          "Add Product",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Cover Image
            const Text(
              "Cover Image (Main Product Image) *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            _buildCoverImagePicker(),

            const SizedBox(height: 25),

            /// 🔹 Product Title
            const Text(
              "Product Title *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: titleController,
              hint: "Enter product title",
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

              const SizedBox(height: 25),

              /// 🔹 Additional Images
              const Text(
                "Additional Images",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _buildAdditionalImagesPicker(),

              const SizedBox(height: 40),

              /// 🔹 Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () {
                    controller.createProduct(
                      title: titleController.text,
                      description: descriptionController.text,
                      price: priceController.text,
                      discountPrice: discountPriceController.text,
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
                          "Add Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    //  ),
    );
  }

  /// 🔹 Cover Image Picker Widget
  Widget _buildCoverImagePicker() {
    return Obx(() {
      return Column(
        children: [
          // Selected Cover Image
          if (controller.coverImage.value != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    controller.coverImage.value!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (controller.coverImage.value != null) const SizedBox(height: 10),
          // Pick Cover Image Button
          GestureDetector(
            onTap: controller.pickCoverImage,
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
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.coverImage.value == null
                        ? "Tap to select cover image"
                        : "Change cover image",
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

  /// 🔹 Additional Images Picker Widget
  Widget _buildAdditionalImagesPicker() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display selected additional images in a grid
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
          if (controller.additionalImages.isNotEmpty) const SizedBox(height: 10),
          // Pick Additional Images Button
          GestureDetector(
            onTap: controller.pickAdditionalImages,
            child: Container(
              height: 100,
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
                    controller.additionalImages.isEmpty
                        ? "Tap to add more images"
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
