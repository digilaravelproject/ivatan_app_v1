import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../data_source/job_data_source.dart';
import '../persentation/controller/applicant_controller.dart';
import '../persentation/controller/job_controller.dart';
import '../persentation/controller/job_discription_controller.dart';
import '../repository/job_repository.dart';

class JobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobRemoteDataSource>(
          () => JobRemoteDataSourceImpl(),
    );

    Get.lazyPut<JobRepository>(
          () => JobRepositoryImpl(Get.find()),
    );

    Get.lazyPut<JobController>(
          () => JobController(Get.find()),
    );

    Get.lazyPut<JobDescriptionController>(
          () => JobDescriptionController(Get.find()),
    );


    Get.lazyPut(() => ApplicantController(Get.find<JobRepository>()));

  }
}
