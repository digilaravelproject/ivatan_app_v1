import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';



class DigitalProductListScreen extends StatelessWidget {
  const DigitalProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: digitalProductList.length,
      itemBuilder: (context, index) {
        return DigitalProductListItem(product: digitalProductList[index]);
      },
    );
  }
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

                      Container(
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
                              'VIEW NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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