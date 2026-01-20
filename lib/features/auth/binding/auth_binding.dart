import 'package:get/get.dart';

import '../controller/login_controller.dart';
import '../controller/register_controller.dart';
import '../data/data_source/auth_remote_data_source.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(), fenix: true);

    Get.lazyPut(
      () => LoginController(authDataSource: Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut(
      () => RegisterController(dataSource: Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );
  }
}
