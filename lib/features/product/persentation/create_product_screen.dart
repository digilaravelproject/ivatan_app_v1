import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/app_urls.dart';
import '../../../core/network/api_services.dart';
import 'my_products_screen.dart';

class CreateProductController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ApiServices apiServices = Get.find<ApiServices>();

  var coverImage = Rx<File?>(null);
  var additionalImages = <dynamic>[].obs; // Can be File or ProductImage
  var isLoading = false.obs;
  var productStatus = 'active'.obs;
  
  // For edit mode
  var isEditMode = false.obs;
  var productId = ''.obs;
  var deletedImageIds = <String>[].obs; // Track deleted IDs (String) to send to server

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
      final image = additionalImages[index];
      if (image is ProductImage) {
        deletedImageIds.add(image.id);
      }
      additionalImages.removeAt(index);
    }
  }

  void loadExistingImages(List<ProductImage> existingImages) {
    additionalImages.clear();
    deletedImageIds.clear(); // Reset deleted tracking
    additionalImages.addAll(existingImages);
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
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validation 2: Check cover image (only required for new products)
    if (!isEditMode.value && coverImage.value == null) {
      Get.snackbar(
        "Error",
        "Please select a cover image",
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
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
        colorText: AppColors.white,
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
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (discountValue >= priceValue) {
        Get.snackbar(
          "Error",
          "Discount price must be less than regular price",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Validation 5: Check image file types (only if new image is selected)
    List<String> validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    
    if (coverImage.value != null) {
      String coverImageExt = coverImage.value!.path.split('.').last.toLowerCase();
      if (!validExtensions.contains(coverImageExt)) {
        Get.snackbar(
          "Error",
          "Cover image must be jpeg, jpg, png, or webp format",
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Check additional images (only File type, not existing ProductImage)
    for (var img in additionalImages) {
      if (img is File) {
        String imgExt = img.path.split('.').last.toLowerCase();
        if (!validExtensions.contains(imgExt)) {
          Get.snackbar(
            "Error",
            "All images must be jpeg, jpg, png, or webp format",
            backgroundColor: AppColors.error,
            colorText: AppColors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    }

    isLoading.value = true;

    try {
      // Check if we have new files to upload
      bool hasNewFiles = coverImage.value != null;
      if (!hasNewFiles) {
        for (var img in additionalImages) {
          if (img is File) {
            hasNewFiles = true;
            break;
          }
        }
      }

      Map<String, dynamic> body = {
        "title": title,
        "description": description,
        "price": priceValue,
        "discount_price": discountPrice.isNotEmpty ? double.parse(discountPrice) : null,
        "stock": stock.isNotEmpty ? int.parse(stock) : 0,
        "status": productStatus.value == 'active' ? 'active' : 'inactive',
      };
      
      // Ensure Laravel resourceful controllers correctly process this POST request as an UPDATE.
      if (isEditMode.value) {
        body["_method"] = "PUT";
      }

      // Add files only if we're using multipart
      if (hasNewFiles) {
        // Add cover image only if selected
        if (coverImage.value != null) {
          body["cover_image"] = coverImage.value;
        }

        // Add additional images with indexed keys (only File type)
        int imageIndex = 0;
        for (var img in additionalImages) {
          if (img is File) {
            body["images[$imageIndex]"] = img;
            imageIndex++;
          }
        }
      }

      // Send deleted image IDs if in edit mode
      if (isEditMode.value && deletedImageIds.isNotEmpty) {
        for (int i = 0; i < deletedImageIds.length; i++) {
          body["deleted_images[$i]"] = deletedImageIds[i];
        }
      }

      late final response;
      
      if (isEditMode.value) {
        // PATCH request for edit
        // Use multipart only if there are new files, otherwise use JSON
        response = await apiServices.callPost(
          "${AppUrls.sellerProducts}/${productId.value}",
          data: body,
          isFormData: hasNewFiles,
        );
      } else {
        // POST request for create - always use multipart
        response = await apiServices.callPost(
          AppUrls.sellerProducts,
          data: body,
          isFormData: true,
        );
      }

      if (response != null && response['success'] == true) {
        final productData = response['data'];
        print("Product ${isEditMode.value ? 'Updated' : 'Created'} Successfully!");
        print("Product ID: ${productData['id']}");
        print("Product UUID: ${productData['uuid']}");
        print("Product Slug: ${productData['slug']}");
        print("Status: ${productData['status']}");
        print("Created At: ${productData['created_at']}");

        // Update product in list by making a fresh API call
        try {
          if (Get.isRegistered<MyProductsController>()) {
            final myProductsController = Get.find<MyProductsController>();
            myProductsController.fetchProducts();
          }
        } catch (e) {
          print('Error fetching products list: $e');
        }

        Get.back();
        Get.snackbar(
          "Success",
          response['message'] ?? "Product ${isEditMode.value ? 'updated' : 'created'} successfully",
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        String errorMsg = response?['message'] ?? "Failed to ${isEditMode.value ? 'update' : 'create'} product";
        print("API VALIDATION ERROR DETAILS: $response");
        if (response != null && response['errors'] != null && response['errors'] is Map) {
          Map errors = response['errors'];
          if (errors.isNotEmpty) {
            var firstKey = errors.keys.first;
            var firstErrorList = errors[firstKey];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMsg = firstErrorList.first.toString();
            }
          }
        }
        Get.snackbar(
          "Error",
          errorMsg,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class CreateProductScreen extends StatelessWidget {
  final ProductModel? product;
  
  CreateProductScreen({super.key, this.product});

  late final CreateProductController controller = Get.put(
    CreateProductController(),
    tag: product?.id ?? 'create',
  );

  late final TextEditingController titleController = TextEditingController(
    text: product?.title ?? '',
  );
  late final TextEditingController descriptionController = TextEditingController(
    text: product?.description ?? '',
  );
  late final TextEditingController priceController = TextEditingController(
    text: product?.price.toString() ?? '',
  );
  late final TextEditingController discountPriceController = TextEditingController(
    text: product?.discountPrice?.toString() ?? '',
  );
  late final TextEditingController stockController = TextEditingController(
    text: product?.stock.toString() ?? '',
  );

  @override
  Widget build(BuildContext context) {
    // Initialize edit mode
    if (product != null) {
      controller.isEditMode.value = true;
      controller.productId.value = product!.id;
      controller.productStatus.value = product!.status;
      // Load existing images
      if (product!.images.isNotEmpty) {
        controller.loadExistingImages(product!.images);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: Text(
          product != null ? "Edit Product" : "Add Product",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.transparent,
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

              /// 🔹 Product Status
              const Text(
                "Product Status",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Obx(() => GestureDetector(
                onTap: () {
                  controller.productStatus.value = 
                    controller.productStatus.value == 'active' ? 'inactive' : 'active';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.productStatus.value == 'active'
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.productStatus.value == 'active'
                          ? AppColors.success
                          : AppColors.premiumGold,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.productStatus.value == 'active'
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                        color: controller.productStatus.value == 'active'
                            ? AppColors.success
                            : AppColors.premiumGold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.productStatus.value == 'active' ? "Active" : "Inactive",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: controller.productStatus.value == 'active'
                              ? AppColors.success
                              : AppColors.premiumGold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

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
                      side: BorderSide(color: AppColors.premiumGold),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          product != null ? "Update Product" : "Add Product",
                          style: TextStyle(
                            color: AppColors.premiumGold,
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

  Widget _buildCoverImagePicker() {
    return Obx(() {
      final hasExistingImage = product != null && 
          product!.coverImage != null && 
          product!.coverImage!.isNotEmpty;
      
      if (controller.coverImage.value != null || hasExistingImage) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: controller.coverImage.value != null
                  ? Image.file(
                      controller.coverImage.value!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    )
                  : Image.network(
                      AppUrls.getFullImageUrl(product!.coverImage!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.premiumGold,
                        height: 200,
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.pickCoverImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: AppColors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Change", style: TextStyle(color: AppColors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return GestureDetector(
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
              Icon(Icons.image_outlined, size: 40, color: AppColors.premiumGold),
              const SizedBox(height: 8),
              Text(
                "Tap to select cover image",
                style: TextStyle(color: AppColors.premiumGold, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 🔹 Additional Images Picker Widget
  Widget _buildAdditionalImagesPicker() {
    return Obx(() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.additionalImages.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.additionalImages.length) {
            // Pick Additional Images Button
            return GestureDetector(
              onTap: controller.pickAdditionalImages,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightBorder, width: 2),
                  color: AppColors.lightBackground,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: AppColors.premiumGold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Add Image",
                      style: TextStyle(
                        color: AppColors.premiumGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final image = controller.additionalImages[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image is File
                    ? Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.network(
                        AppUrls.getFullImageUrl(image.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.premiumGold,
                          child: const Icon(Icons.image, size: 30),
                        ),
                      ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => controller.removeAdditionalImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
        hintStyle: TextStyle(color: AppColors.premiumGold),
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
