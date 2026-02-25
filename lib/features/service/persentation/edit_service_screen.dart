import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import '../controller/service_controller.dart';
import '../model/service_model.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController durationController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.service.title);
    descriptionController = TextEditingController(text: widget.service.description);
    categoryController = TextEditingController(text: widget.service.category);
    priceController = TextEditingController(text: widget.service.price.toString());
    durationController = TextEditingController(text: widget.service.duration);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Service',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Service Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                image: widget.service.images.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.service.images[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.service.images.isEmpty
                  ? const Center(
                      child: Icon(Icons.room_service, size: 50, color: Colors.grey),
                    )
                  : null,
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Service Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter service title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price (₹)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'Duration (e.g., 2 weeks, 1 month)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedService = ServiceModel(
                      id: widget.service.id,
                      title: titleController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      price: double.parse(priceController.text),
                      duration: durationController.text,
                      images: widget.service.images,
                      isActive: widget.service.isActive,
                      userId: widget.service.userId,
                    );

                    controller.updateService(widget.service.id, updatedService);
                    Get.back();
                    Get.snackbar(
                      'Success',
                      'Service updated successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
