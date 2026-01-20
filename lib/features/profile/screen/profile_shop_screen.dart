import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class ProfileShopScreen extends StatefulWidget {
  const ProfileShopScreen({Key? key}) : super(key: key);

  @override
  State<ProfileShopScreen> createState() => _ProfileShopScreenState();
}

class _ProfileShopScreenState extends State<ProfileShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Product"),
            Tab(text: "Service"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(),
              _buildServiceList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    final products = [
      {
        "title": "Wireless Headphone",
        "desc": "Bass is the heartbeat of the music, setting the rhythm.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=2670&auto=format&fit=crop",
        "rating": 5.0
      },
      {
        "title": "Iphone 15",
        "desc": "Bass is the heartbeat of the music, setting the rhythm.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=2670&auto=format&fit=crop",
        "rating": 5.0
      },
       {
        "title": "Water Bottle",
        "desc": "Keep your hydration cool and fresh.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://images.unsplash.com/photo-1602143407151-11115cd4e69b?q=80&w=2574&auto=format&fit=crop",
        "rating": 4.5
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final item = products[index];
        return _buildShopCard(item, isProduct: true);
      },
    );
  }

  Widget _buildServiceList() {
    final services = [
      {
        "title": "Digital Marketing",
        "desc": "The use of digital channels and technologies to promote products.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://plus.unsplash.com/premium_photo-1685086785636-2a1a4e5b552f?q=80&w=2672&auto=format&fit=crop",
        "rating": 3.0
      },
      {
        "title": "SEO",
        "desc": "The practice of improving a website's visibility and ranking.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://images.unsplash.com/photo-1571786256017-aee7a0c009b6?q=80&w=2680&auto=format&fit=crop",
        "rating": 3.0
      },
       {
        "title": "Java Developer",
        "desc": "Expert Java development services for your enterprise.",
        "price": "125.00",
        "oldPrice": "200",
        "image": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=2670&auto=format&fit=crop",
        "rating": 5.0
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return _buildShopCard(item, isProduct: false);
      },
    );
  }

  Widget _buildShopCard(Map<String, dynamic> item, {required bool isProduct}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              item["image"],
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => Container(width: 120, height: 140, color: Colors.grey),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                   Text(
                    item["desc"],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                   Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(" (${item['rating']})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           Text(
                            "₹${item['price']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                           ),
                           const SizedBox(width: 6),
                           Text(
                            "${item['oldPrice']}",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12
                            ),
                           ),
                         ],
                       ),
                        ElevatedButton(
                          onPressed: (){}, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            // minimumSize: const Size(80, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          child: Text(isProduct ? "BUY NOW" : "VIEW NOW", style: const TextStyle(fontSize: 10, color: Colors.white)),
                        )
                     ],
                   )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
