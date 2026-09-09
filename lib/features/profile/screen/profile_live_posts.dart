import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/ownpostController.dart';

class ProfileLivePostsScreen extends StatelessWidget {
  final String username;
  ProfileLivePostsScreen({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Re-use standard controller
    final controller = Get.put(
      OwnPostController(filterType: "posts", UserName: username),
      tag: username.toString(),
      permanent: true,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- GROUP SECTION ---
             _buildSectionHeader("Group", onSeeAll: (){}),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                   // Mock Data
                   final names = ["Art", "Gym", "Travel", "Dance", "SEO", "Design"];
                   final images = [
                     "https://images.unsplash.com/photo-1513364776144-60967b0f800f?q=80&w=2671&auto=format&fit=crop",
                     "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2670&auto=format&fit=crop",
                     "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=2670&auto=format&fit=crop",
                     "https://images.unsplash.com/photo-1545959570-a925b9354971?q=80&w=2671&auto=format&fit=crop",
                     "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=2426&auto=format&fit=crop",
                     "https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=2000&auto=format&fit=crop",
                   ];
                  return Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.premiumGold),
                          image: DecorationImage(
                            image: NetworkImage(images[index % images.length]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(names[index % names.length], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text("12.5k", style: TextStyle(fontSize: 10, color: AppColors.premiumGold)),
                    ],
                  );
                },
              ),
            ),
            
             // --- VIDEOS SECTION ---
            _buildSectionHeader("Videos", onSeeAll: (){}),
            const SizedBox(height: 12),
            SizedBox(
              height: 140, // Slightly smaller than Post for variety or same
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                 itemCount: 5,
                 separatorBuilder: (_, __) => const SizedBox(width: 12),
                 itemBuilder: (context, index) {
                    final videoThumbs = [
                      "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?q=80&w=2670&auto=format&fit=crop",
                      "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=2600&auto=format&fit=crop",
                      "https://images.unsplash.com/photo-1536240478700-b869070f9279?q=80&w=2000&auto=format&fit=crop",
                       "https://images.unsplash.com/photo-1518135714426-587533aee430?q=80&w=2670&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1524253482453-3fed8d2fe12b?q=80&w=2576&auto=format&fit=crop",
                    ];
                    return Stack(
                      children: [
                        Container(
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(videoThumbs[index % videoThumbs.length]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                               const Icon(Icons.play_arrow, color: AppColors.white, size: 16),
                               const SizedBox(width: 4),
                               Text("${(index + 2.1).toStringAsFixed(1)}M", style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold,  shadows: [Shadow(color: AppColors.white, blurRadius: 4)])),
                            ],
                          ),
                        )
                      ],
                    );
                 },
              ),
            ),
             const SizedBox(height: 24),


            // --- LIVE SECTION ---
            const Text(
              "Live",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: Colors.blue, decorationThickness: 2),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage("https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=2670&auto=format&fit=crop"), // Mock Live Image
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                      child: const Row(
                        children: [
                          Icon(Icons.wifi_tethering, color: AppColors.white, size: 14),
                          SizedBox(width: 4),
                          Text("LIVE", style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                     child: Text(
                      "How to perform search engine optimization?",
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14, shadows: [Shadow(color: AppColors.white, blurRadius: 4)]),
                     ),
                   ),
                    Positioned(
                    bottom: 10,
                    right: 10,
                     child: Container(
                       padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                       child: Row(
                         children: [
                           Icon(Icons.remove_red_eye, color: AppColors.white, size: 12),
                           SizedBox(width: 4),
                           Text("40k", style: TextStyle(color: AppColors.white, fontSize: 10)),
                         ],
                       ),
                     )
                   ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- POST SECTION ---
            _buildSectionHeader("Post", onSeeAll: (){}),
            const SizedBox(height: 12),

            SizedBox(
              height: 160,
              child: Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.posts.isEmpty) {
                  return const Center(child: Text("No posts found"));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: controller.posts.length,
                  itemBuilder: (context, index) {
                     final item = controller.posts[index];
                     final String thumb = (item.media.isNotEmpty)
                        ? (item.media.first.thumbnail.isNotEmpty
                        ? item.media.first.thumbnail
                        : item.media.first.url)
                        : "https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg";

                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(thumb),
                          fit: BoxFit.cover,
                          onError: (_,__) {}
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             ),
             Container(height: 3, width: 40, color: Colors.blue, margin: const EdgeInsets.only(top: 4)),
           ],
         ),
        if(onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text("See All", style: TextStyle(color: Colors.blue)))
      ],
    );
  }
}
