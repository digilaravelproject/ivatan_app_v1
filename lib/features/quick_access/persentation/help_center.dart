import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../core/helper/custom_image_view.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/FaqController.dart';
import '../model/FaqModel.dart';

class HelpCenter extends StatelessWidget {
  HelpCenter({super.key});
  final FAQController faqController = Get.put(FAQController());

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leadingWidth: 40, // 👈 default padding kam karega
          titleSpacing: 0,
          backgroundColor: AppColors.transparent,
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.black,
            ),
          ),
          title: Text("Help Center",style: TextStyle(color: AppColors.black,fontWeight: FontWeight.bold,fontSize: 24),),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 16),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 14),
                //   height: 45,
                //   decoration: BoxDecoration(
                //     color: Colors.grey.shade100,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(
                //         CupertinoIcons.search,
                //         color: AppColors.lightTextSecondary,
                //         size: 22,
                //       ),
                //       const SizedBox(width: 10),
                //       Expanded(
                //         child: TextField(
                //           decoration: InputDecoration(
                //             hintText: 'Search FAQs',
                //             hintStyle: TextStyle(
                //               color: AppColors.lightTextSecondary,
                //               fontSize: 16,
                //             ),
                //             border: InputBorder.none,
                //           ),
                //           style: const TextStyle(
                //             fontSize: 16,
                //             color: Colors.black87,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              //  const SizedBox(height: 24),
                const Text(
                  "Frequently Asked Questions",
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Find quick answers to common questions",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                buildFAQList(),
                SizedBox(height: 20),
                const Text(
                  "Contact Support",
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Our team is here to help you 24/7",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Live Agent Chat",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "Available 24/7 for you",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Start Chat",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Direct Contact",
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactTile(
                  icon: CupertinoIcons.phone_fill,
                  title: "Call Us",
                  subtitle: "+91 9594885335",
                  onTap: () => faqController.makePhoneCall("9594885335"),
                ),
                const SizedBox(height: 12),
                _buildContactTile(
                  icon: Icons.mail_rounded,
                  title: "Email Support",
                  subtitle: "info@ivatan.com",
                  onTap: () => faqController.openEmail("info@ivatan.com"),
                ),



              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFAQList() {
    return Obx(() {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: faqController.faqList.length,
        itemBuilder: (context, index) {
          final item = faqController.faqList[index];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => faqController.toggleExpand(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Obx(() => AnimatedRotation(
                        turns: item.isExpanded.value ? 0.5 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 28,
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              // Answer section
              Obx(() => item.isExpanded.value
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  item.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              )
                  : SizedBox()),

              Divider(color: Colors.grey.shade100, height: 24),
            ],
          );
        },
      );
    });
  }


  Widget _buildContactTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
