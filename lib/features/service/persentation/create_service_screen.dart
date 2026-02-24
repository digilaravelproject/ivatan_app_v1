import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateServiceController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var selectedImage = Rx<File?>(null);

  Future<void> pickImageFromGallery() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }
}

class CreateServiceScreen extends StatelessWidget {
  CreateServiceScreen({super.key});

  final CreateServiceController controller =
  Get.put(CreateServiceController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
  TextEditingController();
  final TextEditingController priceController = TextEditingController();

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

            /// 🔹 Service Name
            const Text("Service Name",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: nameController,
              hint: "Enter service name",
            ),

            const SizedBox(height: 20),

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
            const Text("Price",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: priceController,
              hint: "Enter price",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            /// 🔹 Pricing
            const Text("Discount Price",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildTextField(
              controller: priceController,
              hint: "Enter Discount price",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 25),

            /// 🔹 Image Picker
            const Text("Service Image",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            Obx(() {
              return GestureDetector(
                onTap: controller.pickImageFromGallery,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black26),
                    color: Colors.grey.shade100,
                  ),
                  child: controller.selectedImage.value == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Tap to select image"),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(controller.selectedImage.value!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 40),

            /// 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    "Success",
                    "Service Created Successfully",
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Create Service",style: TextStyle(color: Colors.white),),
              ),
            )
          ],
        ),
      ),
    );
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
