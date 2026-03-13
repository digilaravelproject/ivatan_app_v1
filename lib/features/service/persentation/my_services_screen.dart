import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:i_vatan_app/core/widgets/custom_dialog.dart';
import '../../../core/network/app_urls.dart';
import '../controller/service_controller.dart';
import '../model/service_model.dart';
import 'edit_service_screen.dart';
import 'create_service_screen.dart';
import 'widgets/service_detail_bottom_sheet.dart';

class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.put(ServiceController());

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
          'Your Services',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Get.to(() => CreateServiceScreen());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchServices(),
        child: Obx(() {
          if (controller.isLoading.value && controller.services.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty && controller.services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchServices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.services.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.room_service_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No services yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first service to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _buildServiceCard(context, service, controller);
            },
          );
        }),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceModel service, ServiceController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => showServiceDetailBottomSheet(context, service.id, isOwnService: true),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                AppUrls.getFullImageUrl(service.coverImage),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.room_service, size: 50, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: service.status == 'active' ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.status.toUpperCase(),
                          style: TextStyle(
                            color: service.status == 'active' ? Colors.green.shade700 : Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    service.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Price and Duration
                  Row(
                    children: [
                      Icon(Icons.currency_rupee, size: 16, color: Colors.green.shade700),
                      Text(
                        service.price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      if (service.discountPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${service.discountPrice}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(() => EditServiceScreen(service: service));
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          CustomDialog.showConfirmation(
                            title: 'Delete Service',
                            message: 'Are you sure you want to delete this service?',
                            confirmText: 'Delete',
                            onConfirm: () {
                              controller.deleteService(service.id);
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
