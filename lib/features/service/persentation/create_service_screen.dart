import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../controller/create_service_controller.dart';
import '../model/service_model.dart'; // Added
import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';

class CreateServiceScreen extends StatefulWidget {
  final ServiceModel? service;

  const CreateServiceScreen({super.key, this.service});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final CreateServiceController controller = Get.put(CreateServiceController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      controller.initForEdit(widget.service!);
      nameController.text = widget.service!.title;
      descriptionController.text = widget.service!.description;
      priceController.text = widget.service!.price;
      discountPriceController.text = widget.service!.discountPrice ?? '';
    } else {
      controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.service != null ? "Edit Service" : "Create Service",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Image Pickers
            const Text("Cover Image *",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            _buildCoverImagePicker(),

            const SizedBox(height: 25),
            const Text("Additional Images",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            _buildAdditionalImagesPicker(),

            const SizedBox(height: 30),

            /// 🔹 Service Name
            const Text("Service Name *",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: nameController,
              hint: "Enter service name",
            ),

            const SizedBox(height: 20),

            /// 🔹 Description
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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

            const SizedBox(height: 25),

            /// 🔹 Status Toggle
            const Text(
              "Service Status",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Obx(() => GestureDetector(
              onTap: () {
                controller.status.value = 
                  controller.status.value == 'active' ? 'inactive' : 'active';
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: controller.status.value == 'active'
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.status.value == 'active'
                        ? AppColors.success
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.status.value == 'active'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 18,
                      color: controller.status.value == 'active'
                          ? AppColors.success
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.status.value == 'active' ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: controller.status.value == 'active'
                            ? AppColors.success
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                  debugPrint("Update/Create Service button tapped");
                  controller.submitService(
                    title: nameController.text,
                    description: descriptionController.text,
                    price: priceController.text,
                    discountPrice: discountPriceController.text,
                    stock: stockController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
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
                    : Text(
                  widget.service != null ? "Update Service" : "Create Service",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
      final hasExistingImage = controller.existingCoverImageUrl.isNotEmpty;
      
      return GestureDetector(
        onTap: controller.pickCoverImage,
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black12, width: 1.5),
            color: Colors.grey.shade50,
          ),
          child: (controller.coverImage.value == null && !hasExistingImage)
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 45, color: Colors.grey),
              SizedBox(height: 12),
              Text("Select Cover Image", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          )
              : Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: controller.coverImage.value != null
                    ? Image.file(
                  controller.coverImage.value!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
                    : Image.network(
                  controller.existingCoverImageUrl.value,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("Change", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
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
            return GestureDetector(
              onTap: controller.pickAdditionalImages,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12, width: 1.5),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
                      AppUrls.getFullImageUrl((image as ServiceImage).imagePath),
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
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
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
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}
