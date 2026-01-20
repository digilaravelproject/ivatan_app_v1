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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.lightBackgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "i-live chat",
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "120 Friends",
                          style: TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "See All",
                      style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
                    ),
                  ],
                ),
               // SizedBox(height: 20),
                buildFAQList(),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chat with Agent",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "120 Friends",
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CustomImageView(
                        url:
                        "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unknown",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                            Text(
                              "There are many variations of passages of Lorem I psum available",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryDark,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        child: Text(
                          "10:20 AM",
                          style: TextStyle(color: AppColors.darkTextPrimary),
                        ),
                      ),

                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contact Number",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.all(Radius.circular(8),)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 3),
                        child: Icon(CupertinoIcons.phone_down_fill,color: AppColors.white,size: 20,),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        faqController.makePhoneCall("9594885335");
                      },
                        child: Text("+91 9594885335",style: TextStyle(color: AppColors.black,fontSize: 22, fontWeight: FontWeight.w500),))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.all(Radius.circular(8),)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 3),
                        child: Icon(CupertinoIcons.phone_down_fill,color: AppColors.white,size: 20,),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        faqController.makePhoneCall("9594885335");
                      },
                        child: Text("+91 9594885335",style: TextStyle(color: AppColors.black,fontSize: 22,fontWeight:  FontWeight.w500),))
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Email ID",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "See All",
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.all(Radius.circular(8),)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 3),
                        child: Icon(Icons.mail,color: AppColors.white,size: 20,),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        faqController.openEmail("info@ivatan.com");
                      },
                        child: Text("info@ivatan.com",style: TextStyle(color: AppColors.black,fontSize: 22,fontWeight:  FontWeight.w500),))
                  ],
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
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
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
                    fontSize: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              )
                  : SizedBox()),

              Divider(color: AppColors.black),
            ],
          );
        },
      );
    });
  }


}
