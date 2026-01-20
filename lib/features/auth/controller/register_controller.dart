import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_vatan_app/features/auth/persentation/login_screen.dart';

import '../../../../core/helper/custom_snack_bar.dart';
import '../../../route/app_pages.dart';
import '../../dashboard/persentation/dashboard_page.dart';
import '../data/data_source/auth_remote_data_source.dart';
import '../data/model/req/register_req_model.dart';

/*class RegisterController extends GetxController {
  final AuthRemoteDataSource dataSource;

  var isLoading = false.obs;

  RegisterController({required this.dataSource});

  /// Observables for password visibility
  var isPasswordObscure = true.obs;
  var isConfirmPasswordObscure = true.obs;

  /// Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final occupController = TextEditingController();
  final referralController = TextEditingController();
  final addressController = TextEditingController();
  final localityController = TextEditingController();
  final pinCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  /// Form key
  final formKey = GlobalKey<FormState>();

  /// --- VALIDATION LOGIC ---

  String? validateName(String? value) {
    if (value == null) {
      return "Name is required";
    }
    if (value.trim().isEmpty) {
      return "Name is required";
    } else if (value.length < 3) {
      return "Name must be at least 3 characters";
    } else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    if (value == null) {
      return "Email is required";
    }
    if (value.trim().isEmpty) {
      return "Email is required";
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value.trim())) {
      return "Enter a valid email address";
    } else {
      return null;
    }
  }

  String? validatePhone(String? value) {
    if (value == null) {
      return "Phone number is required";
    }
    if (value.trim().isEmpty) {
      return "Phone number is required";
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return "Enter a valid 10-digit phone number";
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value == null) {
      return "Password is required";
    }
    if (value.trim().isEmpty) {
      return "Password is required";
    } else if (value.length < 6) {
      return "Minimum 6 characters required";
    } else {
      return null;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null) {
      return "Confirm password is required";
    }
    if (value.toString().trim().isEmpty) {
      return "Please confirm password";
    } else if (value != passwordController.text.toString()) {
      return "Passwords do not match";
    } else {
      return null;
    }
  }

  /// --- REGISTER ACTION ---
  void onRegister() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    try {
      isLoading.value = true;
      final req = RegisterReqModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        cnfPassword: confirmPasswordController.text.trim(),
      );
      dataSource.makeUserRegister(req);
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}*/

class RegisterController extends GetxController {
  final AuthRemoteDataSource dataSource;

  RegisterController({required this.dataSource});

  var isLoading = false.obs;

  /// Password visibility
  var isPasswordObscure = true.obs;
  var isConfirmPasswordObscure = true.obs;

  /// Occupation list (Dummy for now)
  RxList<String> occupationList = <String>[
    "Student / Learner",
    "Working Professional",
    "Freelancer / Flexible Employee",
    "Business Owner / Self-Employed",
    "Looking for Opportunities",
    "Others (Not Found! Any More creative.)",
  ].obs;

  /// Selected occupation
  RxString selectedOccupation = "".obs;


  /// Text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassworController = TextEditingController();
  final dobController = TextEditingController();
  final occupationController = TextEditingController();
  final interestsController = TextEditingController(); // comma separated: "Reading,Coding"


  /// Form Key
  final formKey = GlobalKey<FormState>();

  /// ----------- VALIDATIONS -----------

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (value.length < 3) return "Enter at least 3 characters";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Email is required";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(value.trim())) {
      return "Enter valid email";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return "Phone number is required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return "Enter valid 10-digit number";
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return "Username required";
    if (value.length < 3) return "Enter at least 3 characters";
    return null;
  }

  String? validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) return "Date of birth required";
    return null;
  }

  // String? validateOccupation(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return "Occupation required";
  //   }
  //   // Minimum 3 characters
  //   if (value.trim().length < 3) {
  //     return "Minimum 3 characters required";
  //   }
  //
  //   // Only text allowed (alphabets + spaces)
  //   final regex = RegExp(r'^[a-zA-Z ]+$');
  //   if (!regex.hasMatch(value.trim())) {
  //     return "Only letters allowed";
  //   }
  //
  //   return null; // valid
  // }

  String? validateOccupation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please select occupation";
    }
    return null;
  }



  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Minimum 8 characters required";
    }
    if (!RegExp(r'.*[A-Za-z].*').hasMatch(value)) {
      return "Password must contain at least 1 alphabet";
    }
    if (!RegExp(r'.*\d.*').hasMatch(value)) {
      return "Password must contain at least 1 number";
    }
    if (!RegExp(r'.*[!@#\$%^&*(),.?\":{}|<>].*').hasMatch(value)) {
      return "Password must contain at least 1 special character";
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Please confirm password";
    if (value != passwordController.text.trim()) {
      return "Passwords do not match";
    }
    if (value.length < 8) {
      return "Minimum 8 characters required";
    }
    if (!RegExp(r'.*[A-Za-z].*').hasMatch(value)) {
      return "Password must contain at least 1 alphabet";
    }
    if (!RegExp(r'.*\d.*').hasMatch(value)) {
      return "Password must contain at least 1 number";
    }
    if (!RegExp(r'.*[!@#\$%^&*(),.?\":{}|<>].*').hasMatch(value)) {
      return "Password must contain at least 1 special character";
    }
    return null;
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      // format date → MM/dd/yyyy
      String formattedDate =
          "${pickedDate.month.toString().padLeft(2, '0')}/"
          "${pickedDate.day.toString().padLeft(2, '0')}/"
          "${pickedDate.year}";

      dobController.text = formattedDate;
    }

  }


  /// ----------- REGISTER ACTION -----------

  void onRegister() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      /// Convert comma separated interests → List<String>
      List<String> interestList = interestsController.text
          .split(",")
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final req = RegisterReqModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        dateOfBirth: dobController.text.trim(),
        occupation: occupationController.text.trim(),
        interests: interestList,
         // ["Coding", "Reading", "Traveling"]
      );

      print("registrationrequset : "+req.name+ req.email+ req.phone+req.username+req.password+req.dateOfBirth+req.occupation+req.interests.toString());

    final modal = await dataSource.makeUserRegister(req);
      final msg = "Congratulations, you have successfully logged in!";

    //  print("registermsg : "+modal.phone);
      //Get.offAllNamed(AppRoutes.login);
      Get.to(LoginPage());
      // Navigator.push(context, DashboardPage() as Route<Object?>);
      CustomSnackBar.showSuccess(message: msg);
    } catch (e) {
      CustomSnackBar.showError(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }



}

