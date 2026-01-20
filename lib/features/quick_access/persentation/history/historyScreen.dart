import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i_vatan_app/core/constants/app_sizer.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
            title: Text("History"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: SingleChildScrollView(
              child:Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          color: AppColors.lightTextSecondary,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Long Video",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 26,
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
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    height: AppSizer.deviceHeight38,
                    // decoration: BoxDecoration(
                    //   color: AppColors.gray,
                    //   borderRadius: BorderRadius.circular(10),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.05),
                    //       blurRadius: 8,
                    //       offset: const Offset(0, 2),
                    //     ),
                    //   ],
                    // ),
                    child:SizedBox(
                      height: 300, // set card height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10, // your dynamic count
                        padding: EdgeInsets.only(left: 16),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 250, // card width
                            margin: EdgeInsets.only(right: 16),
                            child: Stack(
                              children: [
                                // Background Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7)
                                      ],
                                    ),
                                  ),
                                ),

                                // Views Counter (Top Left)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Row(
                                    children: [
                                      Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "views",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bookmark Icon (Top Right)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    Icons.subscriptions,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),

                                // Bottom Icons (Likes, Comments, Share)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(Icons.favorite,
                                                color: Colors.red, size: 32),
                                            Text(
                                              "12.3K",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.comment,
                                                color: Colors.white, size: 32),
                                            Text(
                                              "12.3K",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Icon(Icons.share,
                                                color: Colors.white, size: 32),
                                            Text(
                                              "12.3K",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    /* Stack(
                        children: [
                          // Background Image

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              "https://wallpapers.com/images/high/pretty-profile-pictures-526voksmtgllopn4.webp",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,

                            ),
                          ),


                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                              ),
                            ),
                          ),

                          // Views Counter (Top Left)
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              // decoration: BoxDecoration(
                              //   color: Colors.black.withOpacity(0.5),
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "views",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bookmark Icon (Top Right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              // decoration: BoxDecoration(
                              //   color: Colors.white,
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              child: Icon(
                                Icons.subscriptions,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                          ),

                          // Bottom Content
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Icon(Icons.favorite,color: Colors.red,size: 32,),
                                      Text("12.3K",style: TextStyle(color: AppColors.white,fontSize: 18,fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(Icons.comment,color: Colors.white,size: 32,),
                                      Text("12.3K",style: TextStyle(color: AppColors.white,fontSize: 18,fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(Icons.share,color: Colors.white,size: 32,),
                                      Text("12.3K",style: TextStyle(color: AppColors.white,fontWeight: FontWeight.bold),)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),*/
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
