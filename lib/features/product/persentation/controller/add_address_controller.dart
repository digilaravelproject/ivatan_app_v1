import 'package:get/get.dart';

class AddAddressController extends GetxController {
  var selectedType = "Home".obs;

  void selectType(String type) {
    selectedType.value = type;
  }
}