import 'package:get/get.dart';
import '../../repository/order_repository.dart';
import '../../model/order_model.dart';
import '../../../../core/network/api_services.dart';
import '../../../product/data/repository/marketplace_repository.dart';

class OrderDetailController extends GetxController {
  final int orderId;
  final OrderRepository repository = OrderRepositoryImpl();
  
  var order = Rxn<OrderModel>();
  var isLoading = true.obs;

  OrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    try {
      final response = await repository.getOrderDetails(orderId);
      if (response != null && response['success'] == true) {
        order.value = OrderModel.fromJson(response['data'] ?? {});
      }
    } catch (e) {
      print('Error fetching order details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
