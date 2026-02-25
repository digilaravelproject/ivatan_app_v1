import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/persentation/service_enquire_form.dart' hide AppColors;
import '../../service/persentation/my_services_screen.dart';
import '../../service/controller/service_controller.dart';
import '../../service/model/service_model.dart';



class DigitalProductListScreen extends StatelessWidget {
  final bool isOwnProfile;
  
  const DigitalProductListScreen({super.key, this.isOwnProfile = false});

  @override
  Widget build(BuildContext context) {
    // If it's own profile, show management view (without AppBar)
    if (isOwnProfile) {
      return _MyServicesTabView();
    }
    
    // Otherwise show services with Enquiry buttons
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: digitalProductList.length,
      itemBuilder: (context, index) {
        return DigitalProductListItem(product: digitalProductList[index]);
      },
    );
  }
}

void _showEnquiryBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // For full keyboard support
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const EnquiryForm(),
  );
}

class DigitalProductListItem extends StatelessWidget {
  final DigitalProduct product;

  const DigitalProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                product.imagePath,
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
                  // Title with rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.green,
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: Text(
                      //     '(${product.rating.toStringAsFixed(1)})',
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ],
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
                  ),
                  const SizedBox(height: 8),
                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${product.price.toStringAsFixed(2)} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '₽${product.originalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: (){
                          _showEnquiryBottomSheet(context);
                        },
                        child: Container(
                         // width: double.infinity,
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
                      ),
                    ],
                  ),
                 // const SizedBox(height: 12),
                  // View Now Button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DigitalProduct {
  final String title;
  final String description;
  final double price;
  final double originalPrice;
  final double rating;
  final String imagePath;

  DigitalProduct({
    required this.title,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.imagePath,
  });
}

final List<DigitalProduct> digitalProductList = [
  DigitalProduct(
    title: 'Digital Marketing',
    description: 'The use of digital channels and technologies to promote products, services, and brands.',
    price: 125.00,
    originalPrice: 200.00,
    rating: 3.0,
    imagePath: 'https://m.media-amazon.com/images/I/610ub5kytVL.jpg',
  ),
  DigitalProduct(
    title: 'SEO',
    description: 'The practice of improving a website\'s visibility and ranking in search engine results pages',
    price: 125.00,
    originalPrice: 200.00,
    rating: 3.0,
    imagePath: 'https://m.media-amazon.com/images/I/610ub5kytVL.jpg',
  ),
  DigitalProduct(
    title: 'Java Developer',
    description: 'Complete Java development course from beginner to advanced level with hands-on projects',
    price: 149.00,
    originalPrice: 250.00,
    rating: 4.5,
    imagePath: 'https://m.media-amazon.com/images/I/610ub5kytVL.jpg',
  ),
  DigitalProduct(
    title: 'Python Programming',
    description: 'Learn Python programming language with practical examples and real-world applications',
    price: 135.00,
    originalPrice: 220.00,
    rating: 4.2,
    imagePath: 'https://m.media-amazon.com/images/I/610ub5kytVL.jpg',
  ),
];


// Wrapper widget for tab view (without AppBar)
class _MyServicesTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceController());
    
    return Obx(() {
      if (controller.services.isEmpty) {
        return Center(
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
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
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
                    service.images.isNotEmpty ? service.images[0] : '',
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
                      color: service.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      service.isActive ? 'Active' : 'Inactive',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          service.category,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${service.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
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
