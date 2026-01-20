import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/core/theme/app_colors.dart';

import '../controller/navigationController.dart';

/*class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.put(NavigationController());
    DateTime? lastPressed;

    return
      PopScope(

        canPop: false, // BACK gesture ko override karne ke liye required
        onPopInvoked: (didPop) {
          if (didPop) return; // agar flutter ne already pop kar diya

          // Agar home par nahi ho → home page par jao
          if (navController.currentIndex.value != 0) {
            navController.changePage(0);
            return;
          }

          // Double back exit logic
          final now = DateTime.now();
          if (lastPressed == null ||
              now.difference(lastPressed!) > const Duration(seconds: 2)) {
            lastPressed = now;

            Get.snackbar(
              "Exit App",
              "Press again to exit",
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
            return;
          }

          // Exit app
          SystemNavigator.pop();
        },
      *//*onWillPop: () async {
        // अगर Home पर नहीं हैं → Home पर भेज दो
        if (navController.currentIndex.value != 0) {
          navController.changePage(0);
          return false;
        }

        // Home screen पर हैं → Double back handle
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;

          Get.snackbar(
            "Exit App",
            "Press again to exit",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );

          return false;
        }

        return true; // Exit app
      },*//*
      child: Obx(() => Scaffold(
        body: navController.getCurrentPage(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryDark,
            unselectedItemColor: Colors.grey[600],
            // currentIndex: navController.currentIndex.value,
            // onTap: navController.changePage,
            currentIndex: navController.currentIndex.value > 4
                ? 3
                : navController.currentIndex.value,
            onTap: navController.changePage,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                  label: "Home"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                  label: "Search"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.slow_motion_video),
                  label: "Reels"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_collection_outlined),
                  label: "Videos"
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_pin),
                label: "Profile"
              ),
            ],
          ),
        ),
      )),
    );
  }
}*/


class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController controller =
  Get.put(DashboardController());

  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > const Duration(seconds: 2)) {
          lastPressed = now;
          Get.snackbar(
            "Exit App",
            "Press again to exit",
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.white,
        body: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: controller.screenList,
        ),

      /*  floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => controller.changeIndex(2),
          child: const Icon(Icons.slow_motion_video),
        ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _item(context, Icons.home, "Home", 0),
                _item(context, Icons.search, "Search", 1),
              ]),
              Row(children: [
                _item(context, Icons.video_collection_outlined, "Videos", 3),
                _item(context, Icons.person, "Profile", 4),
              ]),
            ],
          ),
        ),*/

        floatingActionButton: Container(
          height: 50, // size of the circular button
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => controller.changeIndex(2),
            backgroundColor: Colors.transparent, // make button circular with container color
            elevation: 0,
            child: const Icon(Icons.slow_motion_video, size: 30,color: AppColors.white,),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
       /* bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: SizedBox(
            height: 30, // reduce bottom nav height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _item(context, Icons.home, "Home", 0),
                  _item(context, Icons.search, "Search", 1),
                ]),
                Row(children: [
                  _item(context, Icons.video_collection_outlined, "Videos", 3),
                  _item(context, Icons.person, "Profile", 4),
                ]),
              ],
            ),
          ),
        ),*/
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          height: 65, // Add this line to control the overall height
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0), // Optional: adjust padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _item(context, Icons.home, "Home", 0),
                  _item(context, Icons.search, "Search", 1),
                ]),
                Row(children: [
                  _item(context, Icons.video_collection_outlined, "Videos", 3),
                  _item(context, Icons.person, "Profile", 4),
                ]),
              ],
            ),
          ),
        ),

      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? AppColors.black : Colors.grey;

      return InkWell(
        onTap: () => controller.changeIndex(index),
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22), // Reduce icon size
              const SizedBox(height: 2), // Add spacing
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11, // Reduce font size
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
 /* Widget _item(BuildContext context, IconData icon,
      String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color =
      isSelected ? AppColors.primary : Colors.grey;

      return InkWell(
        onTap: () => controller.changeIndex(index),
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ],
          ),
        ),
      );
    });
  }*/
}


class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Business Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            _buildFeaturedBusiness(),
            const SizedBox(height: 20),
            _buildTabButtons(),
            const SizedBox(height: 20),
            _buildOtherBusinessesCard(),
            const SizedBox(height: 20),
            _buildOtherBusinessesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBusiness() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Sadhna Pharmacy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Product Business',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Created 4 days ago',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD63384),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                   // vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ENQUIRY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Featured Business',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD63384),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'All Businesses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Color(0xFFD63384), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'My Business',
                style: TextStyle(
                  color: Color(0xFFD63384),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherBusinessesCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD63384), Color(0xFFE85D9A)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Other Businesses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Explore more business opportunities',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '2',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD63384),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherBusinessesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Other Businesses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildBusinessCard(
          'Cipla Industry',
          'Product Business',
          'Pune, Maharashtra',
          'Nov 4, 2025',
        ),
        _buildBusinessCard(
          'Mcure Pharma',
          'Product Business',
          'Pune, Maharashtra',
          'Nov 4, 2025',
        ),
      ],
    );
  }

  Widget _buildBusinessCard(
      String name,
      String type,
      String location,
      String date,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            location,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Created $date',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See detail',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}