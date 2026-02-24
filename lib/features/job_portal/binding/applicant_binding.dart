import 'package:get/get.dart';
import '../persentation/controller/applicant_controller.dart';
import '../repository/job_repository.dart';

class ApplicantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicantController(Get.find<JobRepository>()));
  }
}
