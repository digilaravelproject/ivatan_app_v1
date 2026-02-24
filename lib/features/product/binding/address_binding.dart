 import 'package:get/get.dart';

import '../persentation/controller/add_address_controller.dart';

class AddressBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<AddAddressController>(
          () => AddAddressController(),
    );

  }

}