import 'package:get/get.dart';
import '../../data/repository/marketplace_repository.dart';
import '../../repository/order_repository.dart';
import '../../model/order_model.dart';
import '../../../../core/network/api_services.dart';

class MyOrdersController extends GetxController {
  final OrderRepository repository = OrderRepositoryImpl();
  
  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({int page = 1}) async {
    if (page == 1) {
      isLoading.value = true;
    }

    try {
      final response = await repository.getOrders(page: page);
      if (response != null && response['success'] == true) {
        final List<dynamic> data = response['data']['data'] ?? [];
        final List<OrderModel> fetchedOrders = data.map((json) => OrderModel.fromJson(json)).toList();

        if (page == 1) {
          orders.value = fetchedOrders;
        } else {
          orders.addAll(fetchedOrders);
        }

        currentPage.value = response['data']['current_page'] ?? 1;
        lastPage.value = response['data']['last_page'] ?? 1;
      }
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (currentPage.value < lastPage.value) {
      await fetchOrders(page: currentPage.value + 1);
    }
  }

  void refreshOrders() {
    currentPage.value = 1;
    orders.clear();
    fetchOrders();
  }
}
