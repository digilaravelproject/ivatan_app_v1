import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/auth/persentation/registration_screen.dart';
import 'package:i_vatan_app/features/auth/persentation/verifyOtp.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_buttons.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/persentation/dashboard_page.dart';
import '../controller/intrest_controller.dart';
import '../controller/register_controller.dart';
import '../widgets/auth_input_fields.dart';

/*class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼 Background header container
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(AppAssets.imgAuthBack),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📜 Scrollable content below header
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            "Interest",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text("1. Technology",style: TextStyle(color: AppColors.black,fontSize: 18,fontWeight: FontWeight.bold),),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Web Development"),
                            Text("Software Engineering"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Web Development"),
                            Text("Software Engineering"),
                          ],
                        ),
                     


                        MyButton(
                          title: "Submit",
                          onPressed: () {
                            Get.to(VerifyOtp());
                          },
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          height: 40,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 16),

                      ],
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
}*/

class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final InterestController controller = Get.put(InterestController());
 // final RegisterController registerController = Get.find();
  final RegisterController registerController = Get.find<RegisterController>();


  final Set<String> selectedItems = {};

  void toggleSelection(String item) {
    setState(() {
      selectedItems.contains(item)
          ? selectedItems.remove(item)
          : selectedItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              image: const DecorationImage(
                image: AssetImage(AppAssets.imgAuthBack),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Interest",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // 🔥 API DATA LOOP
                          for (var category in controller.interestData) ...[
                            Text(
                              category["category"],
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Wrap(
                              spacing: 20,
                              runSpacing: 10,
                              children: (category["interests"] as List<dynamic>)
                                  .map(
                                    (item) => SelectableOption(
                                  title: item,
                                  isSelected: selectedItems.contains(item),
                                  onTap: () => toggleSelection(item),
                                ),
                              )
                                  .toList(),
                            ),

                            const SizedBox(height: 20),
                          ],

                          const SizedBox(height: 20),

                          Center(
                            child: MyButton(
                              title: "Next ",
                              onPressed: () {
                                if (selectedItems.isEmpty) {
                                  CustomSnackBar.showError( message: 'Please select at least one interest');
                                  return;
                                }

                                registerController.interestsController.text =
                                    selectedItems.join(",");

                                Get.to(() => RegistrationScreen());

                                print("Selected => $selectedItems");
                              },
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primary],
                              ),
                              height: 40,
                              borderRadius: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/*class InterestScreen extends StatefulWidget {
  const InterestScreen({Key? key}) : super(key: key);

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  // 🧾 Define interest data
  final Map<String, List<String>> interests = {
    "Technology": [
      "Web Development",
      "Software Engineering",
      "App Development",
      "Data Science"
    ],
    "Sports": ["Cricket", "Football", "Tennis", "Badminton"],
    "Arts & Culture": ["Painting", "Music", "Dance", "Photography"],
  };


  final Set<String> selectedItems = {};

  void toggleSelection(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  // 🛰 API sending example
  void submitSelections() {
    // Example: Convert selected data to JSON-like payload
    final data = {"interests": selectedItems.toList()};
    print("Selected data to send API => $data");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(AppAssets.imgAuthBack),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Interest",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 🏷 Generate interest sections dynamically
                        for (var entry in interests.entries) ...[
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: entry.value
                                .map(
                                  (item) => SelectableOption(
                                title: item,
                                isSelected: selectedItems.contains(item),
                                onTap: () => toggleSelection(item),
                              ),
                            )
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        const SizedBox(height: 20),

                        Center(
                          child: MyButton(
                            title: "Submit",
                            onPressed: (){
                              Get.to(NavigationScreen());
                            },
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primary],
                            ),
                            height: 40,
                            borderRadius: 8,
                          ),
                        ),
                      ],
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
}*/

class SelectableOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableOption({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👇 Circle indicator like a radio button
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

