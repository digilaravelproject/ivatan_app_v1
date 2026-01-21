import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:i_vatan_app/features/dashboard/persentation/comming_soon.dart';
import 'package:i_vatan_app/features/dashboard/persentation/search_screen.dart'; // Import SearchScreen

import '../../../core/constants/app_assets.dart';
import '../../../core/helper/custom_snack_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_decoration.dart';
import '../../../core/utils/basic_text_field.dart';
import '../../../core/utils/country_list_picker.dart';
import '../../../core/utils/custom_buttons.dart';
import '../../../route/app_pages.dart';
import 'contact_screen.dart';
import 'group_screen.dart';
import 'message_screen.dart';
class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  int _selectedIndex = 1; // Default to Message (index 1)

  final List<Widget> _pages = [
    ComingSoonScreen(), // Back to Main
    MessageListScreen(), // Message
    ComingSoonScreen(), // Call
    ContactPerson(), // Contact
    GroupScreen(), // Group
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 65,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.arrow_back_ios_rounded,
                  label: 'Back to Main',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Message',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.contacts_rounded,
                  label: 'Contact',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.group_rounded,
                  label: 'Group',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate to main screen
          Get.offAllNamed(AppRoutes.navigationScreen);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0), // Reduced Padding
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.lightTextSecondary,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.lightTextSecondary,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class LoginPage123 extends StatelessWidget {
   LoginPage123({super.key});

  final LoginController controller =
  Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7AB6F0),
              Color(0xFFB3E5F5),
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // vsync: controller,
        // behaviour: RandomParticleBehaviour(
        //   options: ParticleOptions(
        //     maxOpacity: 0.9,
        //     minOpacity: 0.3,
        //     baseColor: context.theme.colorScheme.onPrimary,
        //     opacityChangeRate: 0.75,
        //     particleCount: 70,
        //     spawnMaxSpeed: 80,
        //     spawnMinSpeed: 30,
        //     image: Image.asset(
        //       AppAssets.imgAppLogo,
        //       height: 50,
        //       width: 50,
        //       color: context.theme.colorScheme.onPrimary,
        //     ),
        //   ),
        // ),
        child: Stack(
          children: [
            Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: AppDecorations.bottomSheetDecoration(context),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Welcome Text
                          Text(
                            "Find Your Perfect Match 💖",
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter your mobile number and start connecting with amazing date!",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// Phone Number Input
                          Text(
                            "Mobile Number".toUpperCase(),
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                          ),                          const SizedBox(height: 8),

                          Obx(() {
                            var p = controller.selectedPhone.value;
                            return Column(
                              children: [
                                TextFormField(
                                  focusNode: FocusNode(canRequestFocus: true),
                                  controller: controller.mobileController,
                                  maxLength: p.maxLength,
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: context.textTheme.titleMedium,
                                  validator: (v) {
                                   // return FormValidator.mobile(v, country: p);
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    prefixIcon: Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: context.theme.dividerColor,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: controller.pickCountry,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              p.flag,
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              p.displayCC,
                                              style: context
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).marginSymmetric(vertical: 12),
                                    hintText:
                                    "Your ${p.maxLength}-digit mobile number",
                                    hintStyle: context.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                if (controller.isLoginPass.value) ...[
                                  ValueListenableBuilder(
                                    valueListenable:
                                    controller.mobileController,
                                    builder: (context, value, child) {
                                      return Text(
                                        'We will send OTP on \n ${p.displayCC} ${value.text} to verify you',
                                        style: context.textTheme.titleMedium,
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ).marginOnly(top: 30, bottom: 11),
                                ] else ...[
                                  AppInputTextField(
                                    label: "Password",
                                    isObscure: controller.isShowPassword.value,
                                   // validator: FormValidator.password,
                                    iconData: CupertinoIcons.lock_fill,
                                    controller: controller.passwordController,
                                    endIcon: controller.isShowPassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    onEndIconTap: () {
                                      controller.isShowPassword.toggle();
                                    },
                                  ).marginOnly(top: 12),
                                ],
                              ],
                            );
                          }),

                          Obx(
                                () => Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: controller.isLoginPass.value,
                                    onChanged: (v) {
                                      controller.isLoginPass.toggle();
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Login with otp",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ).marginSymmetric(vertical: 22),

                          Obx(
                                () => CustomButton(
                              title: "GET OTP & FIND LOVE",
                              onPressed: (){

                              },
                              isLoading: controller.isLoading.value,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Terms and Privacy
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "By continuing, you agree to our\n",
                                  ),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      color: context.theme.primaryColor,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        debugPrint("Privacy Policy clicked");
                                      },
                                  ),
                                  const TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                      color: context.theme.primaryColor,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        debugPrint("Terms of Service clicked");
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.mediaQueryPadding.bottom),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      /*  Stack(
          children: [
            Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: AppDecorations.bottomSheetDecoration(context),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Welcome Text
                          Text(
                            "Find Your Perfect Match 💖",
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enter your mobile number and start connecting with amazing date!",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// Phone Number Input
                          Text(
                            "Mobile Number".toUpperCase(),
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: context.isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Obx(() {
                            var p = controller.selectedPhone.value;
                            return Column(
                              children: [
                                TextFormField(
                                  focusNode: FocusNode(canRequestFocus: true),
                                  controller: controller.mobileController,
                                  maxLength: p.maxLength,
                                  autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: context.textTheme.titleMedium,
                                  // validator: (v) {
                                  //   return FormValidator.mobile(v, country: p);
                                  // },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    prefixIcon: Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: context.theme.dividerColor,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: controller.pickCountry,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              p.flag,
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              p.displayCC,
                                              style: context
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).marginSymmetric(vertical: 12),
                                    hintText:
                                    "Your ${p.maxLength}-digit mobile number",
                                    hintStyle: context.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                if (controller.isLoginPass.value) ...[
                                  ValueListenableBuilder(
                                    valueListenable:
                                    controller.mobileController,
                                    builder: (context, value, child) {
                                      return Text(
                                        'We will send OTP on \n ${p.displayCC} ${value} to verify you',
                                        style: context.textTheme.titleMedium,
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ).marginOnly(top: 30, bottom: 11),
                                ] else ...[
                                  AppInputTextField(
                                    label: "Password",
                                    isObscure: controller.isShowPassword.value,
                                   // validator: FormValidator.password,
                                    iconData: CupertinoIcons.lock_fill,
                                    controller: controller.passwordController,
                                    endIcon: controller.isShowPassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    onEndIconTap: () {
                                      controller.isShowPassword.toggle();
                                    },
                                  ).marginOnly(top: 12),
                                ],
                              ],
                            );
                          }),

                          Obx(
                                () => Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: controller.isLoginPass.value,
                                    onChanged: (v) {
                                      controller.isLoginPass.toggle();
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Login with otp",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ).marginSymmetric(vertical: 22),

                          Obx(
                                () => CustomButton(
                              title: "GET OTP & FIND LOVE",
                              onPressed: (){

                              },
                              isLoading: controller.isLoading.value,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Terms and Privacy
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "By continuing, you agree to our\n",
                                  ),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      color: context.theme.primaryColor,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        debugPrint("Privacy Policy clicked");
                                      },
                                  ),
                                  const TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                      color: context.theme.primaryColor,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        debugPrint("Terms of Service clicked");
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.mediaQueryPadding.bottom),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),*/
      ),
    );
  }
}



class LoginController extends GetxController
    implements GetTickerProviderStateMixin {
  //LoginDataSource dataSource;

  LoginController();

  var mobileController = TextEditingController();
  var passwordController = TextEditingController();

  var isLoginPass = true.obs;
  var isShowPassword = true.obs;
  var selectedPhone = countries.where((p) => p.dialCode == "91").first.obs;

  var countryController = TextEditingController();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();




  @override
  void onInit() {
    _initCountry();
    super.onInit();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  @override
  void didChangeDependencies(BuildContext context) {}

  void pickCountry() {
    Get.to(() => CountriesList(onTap: (p) => selectedPhone.value = p));
  }

/*  Future<void> performLogin() async {
    try {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        var res = await dataSource.makeOtpLoginRequest(
          ReqLoginModel(
            phoneCode: selectedPhone.value.displayCC,
            mobileNumber: mobileController.text,
            password: passwordController.text,
            isLoginPass: !isLoginPass.value,
          ),
        );
        CustomSnackBar.showSuccess(
          message: res,
          position: SnackBarPosition.top,
        );
        VerifyOtpBottomSheet.show(this);
      }
    } catch (e, stk) {
      CustomSnackBar.showError(message: e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    try {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        var _ = await dataSource.verifyUserOTP(
          ReqOTPModel(
            phoneCode: "+91",
            mobileNumber: mobileController.text,
            isLoginPass: !isLoginPass.value,
            otp: '',
          ),
        );
      }
    } catch (e, stk) {
      CustomSnackBar.showError(message: e.toString());
      printMessage("performLogin $stk");
    } finally {
      isLoading.value = false;
    }
  }*/

  void _initCountry() {}
}



class LoopHomeScreen extends StatelessWidget {
  const LoopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/background.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // optional dark overlay
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Stories Section
                  _buildStories(),

                  // Feed
                  Expanded(
                    child: ListView(
                      children: [
                        _buildPost(
                          username: 'mindcast',
                          verified: true,
                          likes: '107k',
                          time: '12h ago',
                        ),
                        _buildPost(
                          username: 'moodrealms',
                          verified: true,
                          likes: '89k',
                          time: '5h ago',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // bottomNavigationBar: _buildBottomNavigation(context),
      );

  }

  // Header Widget
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'I - Vatan',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white
              ,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.notifications,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stories Widget
  Widget _buildStories() {
    final stories = [
      {'name': 'Your Loop', 'isNew': true},
      {'name': 'mindcast', 'isNew': false},
      {'name': 'vibeteller', 'isNew': false},
      {'name': 'moodrealms', 'isNew': false},
      {'name': 'inkdrop', 'isNew': false},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: story['isNew'] == true
                              ? [Colors.purple, Colors.pink]
                              : [Colors.orange, Colors.pink],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3), // border thickness
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (story['isNew'] == true)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story['name'] as String,
                  style: const TextStyle(fontSize: 12,color: AppColors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Post Widget
  Widget _buildPost({
    required String username,
    required bool verified,
    required String likes,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade500],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.white
                          ),
                        ),
                        if (verified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const Text(
                      '🎵 Imam Malboo • Neha Nair, Kinanu Kondu',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert,color: AppColors.white,),
            ],
          ),
        ),

        // Post Image
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300,
                      Colors.orange.shade200,
                      Colors.orange.shade100,
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg",
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Row(
                  children: [
                    Row(
                      children: [
                        _buildLikeAvatar(Colors.red.shade400),
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: _buildLikeAvatar(Colors.blue.shade400),
                        ),
                        Transform.translate(
                          offset: const Offset(-16, 0),
                          child: _buildLikeAvatar(Colors.pink.shade400),
                        ),
                      ],
                    ),
                    Text(
                      '$likes Liked',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.send,color: AppColors.white, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.more_horiz,color: AppColors.white, size: 28),
            ],
          ),
        ),

        // Post Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '@vibeteller, @mooddreamlms and others liked this post!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '@mindcast soft hues, slow days, and a heart full of stillness ☕ ...more',
                style: TextStyle(fontSize: 14,color: AppColors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLikeAvatar(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  // Bottom Navigation
  Widget _buildBottomNavigation(context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.search, 'Search', false),
              const SizedBox(width: 60),
              _buildNavItem(Icons.repeat, 'Loops', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
          Positioned(
            top: -20,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});
  final DashboardController controller =
  Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        extendBody: true,
        body: PageView(
          controller: controller.pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (position) => controller.selectedIndex(position),
          children: controller.screenList,
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          onPressed: () => controller.changeIndex(2),
          child: const Icon(Icons.slow_motion_video, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 65,
          shadowColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  _buildBottomNavItem(
                    context,
                    icon: CupertinoIcons.house_fill,
                    label: "Home",
                    index: 0,
                  ),
                  _buildBottomNavItem(
                    context,
                    icon: Icons.search,
                    label: "Search",
                    index: 1,
                  ),
                ],
              ),
              Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBottomNavItem(
                    context,
                    icon: Icons.video_collection_outlined,
                    label: "Videos",
                    index: 3,
                  ),
                  _buildBottomNavItem(
                    context,
                    icon: CupertinoIcons.person_crop_circle,
                    label: "Profile",
                    index: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  }

  Widget _buildBottomNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    return InkWell(
      onTap: () => controller.changeIndex(index),
      borderRadius: BorderRadius.circular(30),
      child: SizedBox.square(
        dimension: 60,
        child: Center(
          child: Obx(() {
            final isSelected = controller.selectedIndex.value == index;
            final color =
            isSelected ? AppColors.primary : context.theme.iconTheme.color;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class DashboardController extends GetxController {
  /// Bottom nav selected index
  final RxInt selectedIndex = 0.obs;

  /// PageView controller
  late PageController pageController;

  /// Screens list (order IMPORTANT)
  final List<Widget> screenList = [
    LoopHomeScreen(),     // index 0
    LoopHomeScreen(), // index 1
    LoopHomeScreen(),   // index 2 (FAB)
    LoopHomeScreen(),   // index 3
    LoopHomeScreen(),  // index 4
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedIndex.value);
  }

  /// Bottom nav / FAB tap
  void changeIndex(int index) {
    selectedIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// PageView swipe (future use)
  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}













class DatingLoginScreen extends StatelessWidget {
  const DatingLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pink gradient background with hearts
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7AB6F0),
                  Color(0xFFB3E5F5),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

          ),

          // Bottom sheet with login form
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          children: const [
                            Text(
                              'Login With I-Vatan ',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '💖',
                              style: TextStyle(fontSize: 26),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        const Text(
                          'Enter your mobile number and start connecting with amazing date!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Mobile Number Label
                        const Text(
                          'MOBILE NUMBER',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Phone Number Input
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Country Code Selector
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                child: Row(
                                  children: const [
                                    Text('🇮🇳', style: TextStyle(fontSize: 24)),
                                    SizedBox(width: 8),
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),

                              // Divider
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                              ),

                              // Phone Number Field
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: '9651017054',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OTP Info Text
                        Center(
                          child: Column(
                            children: const [
                              Text(
                                'We will send OTP on',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '+91 9651017054 to verify you',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login with OTP Checkbox
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Login with otp',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Get OTP Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'GET OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Conditions
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              children: [
                                const TextSpan(text: 'By continuing, you agree to our\n'),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
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

  Widget _buildHeart(double size, double opacity) {
    return Icon(
      Icons.favorite,
      size: size,
      color: Colors.pink[100]!.withOpacity(opacity),
    );
  }
}


