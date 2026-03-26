import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/app_urls.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../controller/service_controller.dart';
import '../../model/service_model.dart';
import '../create_service_screen.dart';
import '../service_enquire_form.dart';

void _showEnquiryBottomSheet(BuildContext context, int sellerId, int serviceId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => EnquiryForm(sellerId: sellerId, serviceId: serviceId),
  );
}

void showServiceDetailBottomSheet(BuildContext context, int serviceId, {bool isOwnService = false}) {
  final ServiceController controller = Get.find<ServiceController>();
  controller.fetchServiceDetail(serviceId);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Obx(() {
      if (controller.isDetailLoading.value) {
        return _buildLoadingSheet(context);
      }

      final service = controller.selectedService.value;
      if (service == null) {
        return _buildErrorSheet(context);
      }

      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _buildServiceDetailContent(context, service),
                  ),
                ),
                _buildActionButtons(context, service, isOwnService),
              ],
            ),
          );
        },
      );
    }),
  );
}

Widget _buildLoadingSheet(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.9,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}

Widget _buildErrorSheet(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.9,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
    ),
    child: const Center(child: Text("Service not found")),
  );
}

Widget _buildServiceDetailContent(BuildContext context, ServiceModel service) {
  double originalPrice = double.tryParse(service.price) ?? 0;
  double discountPrice = double.tryParse(service.discountPrice ?? "0") ?? 0;
  double discountPercentage = 0;
  if (originalPrice > 0 && discountPrice > 0) {
    discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: Image.network(
                AppUrls.getFullImageUrl(service.coverImage),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: service.status == 'active' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                service.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (discountPercentage > 0)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${discountPercentage.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Service ID: #${service.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${service.discountPrice ?? service.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (service.discountPrice != null && service.discountPrice != service.price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${service.price}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),
            if (service.images.isNotEmpty) ...[
              const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: service.images.length,
                  itemBuilder: (context, index) {
                    final img = service.images[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          AppUrls.getFullImageUrl(img.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (service.seller != null) ...[
              const Text(
                'Seller Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: service.seller!.profilePhotoPath != null
                      ? NetworkImage(AppUrls.getFullImageUrl(service.seller!.profilePhotoPath))
                      : null,
                  child: service.seller!.profilePhotoPath == null ? const Icon(Icons.person) : null,
                ),
                title: Text(service.seller!.name ?? ""),
                subtitle: Text(service.seller!.occupation ?? ""),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    ],
  );
}

Widget _buildActionButtons(BuildContext context, ServiceModel service, bool isOwnService) {
  final ServiceController controller = Get.find<ServiceController>();

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: isOwnService 
      ? Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => CreateServiceScreen(service: service));
                },
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Edit Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  CustomDialog.showConfirmation(
                    title: 'Delete Service',
                    message: 'Are you sure you want to delete this service?',
                    confirmText: 'Delete',
                    onConfirm: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close bottom sheet
                      controller.deleteService(service.id);
                    },
                  );
                },
                icon: const Icon(Icons.delete, size: 20),
                label: const Text('Delete Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        )
      : Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEnquiryBottomSheet(context, service.seller!.id!, service.id);
                },
                icon: const Icon(Icons.mail_outline, size: 20),
                label: const Text('Send Enquiry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}
