import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/app_urls.dart';
import '../../../core/theme/app_colors.dart';
import '../../service/model/service_model.dart';
import '../../service/persentation/service_enquire_form.dart' hide AppColors;
import '../../service/persentation/my_services_screen.dart';
import '../../service/controller/service_controller.dart';
import '../../service/persentation/widgets/service_detail_bottom_sheet.dart';

class DigitalProductListScreen extends StatefulWidget {
  final bool isOwnProfile;
  final String? userId;
  
  const DigitalProductListScreen({super.key, this.isOwnProfile = false, this.userId});

  @override
  State<DigitalProductListScreen> createState() => _DigitalProductListScreenState();
}

class _DigitalProductListScreenState extends State<DigitalProductListScreen> {
  late final ServiceController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ServiceController(userId: widget.userId),
      tag: widget.userId ?? 'global',
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.fetchMarketplaceServices();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If it's own profile, show management view (without AppBar)
    // if (widget.isOwnProfile) {
    //   return _MyServicesTabView();
    // }
    
    return Obx(() {
      if (controller.isMarketplaceLoading.value && controller.marketplaceServices.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty && controller.marketplaceServices.isEmpty) {
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
            ],
          ),
        );
      }

      if (controller.marketplaceServices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.room_service_outlined, size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              const Text('No products found', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchMarketplaceServices(isRefresh: true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 0),
          itemCount: controller.marketplaceServices.length + (controller.hasMoreMarketplace.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.marketplaceServices.length) {
              return Obx(() => controller.isMarketplaceLoading.value 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink());
            }
            return DigitalProductListItem(product: controller.marketplaceServices[index], userId: widget.userId);
          },
        ),
      );
    });
  }
}

void _showEnquiryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // For full keyboard support
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        height: 200,
        child: Center(
          child: Text("Bottom Sheet Content"),
        ),
      );
    }
    //const EnquiryForm(sellerId: , serviceId: ,),
  );
}

class DigitalProductListItem extends StatelessWidget {
  final ServiceModel product;
  final String? userId;

  const DigitalProductListItem({super.key, required this.product, this.userId});

  @override
  Widget build(BuildContext context) {
    final ServiceController controller = Get.find<ServiceController>(tag: userId ?? 'global');
    
    return GestureDetector(
      onTap: () {
        if (product.id != null) {
          showServiceDetailBottomSheet(context, product.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  AppUrls.getFullImageUrl(product.coverImage),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Description
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            if (product.discountPrice != null && product.discountPrice!.isNotEmpty)
                              Text(
                                '₹${product.discountPrice}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),

                        /*InkWell(
                          onTap: (){
                            _showEnquiryBottomSheet(context);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'Enquiry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Wrapper widget for tab view (without AppBar)
class _MyServicesTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.room_service_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No services yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.services.length,
        itemBuilder: (context, index) {
          final service = controller.services[index];
          return _buildServiceCard(service, controller);
        },
      );
    });
  }

  Widget _buildServiceCard(ServiceModel service, ServiceController controller) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    AppUrls.getFullImageUrl(service.coverImage),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.room_service, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: service.status == 'active' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      service.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Service Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.shade50,
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: Text(
                      //     'Service',
                      //     style: TextStyle(
                      //       color: Colors.blue.shade700,
                      //       fontSize: 9,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${service.price}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (service.discountPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '₹${service.discountPrice}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}