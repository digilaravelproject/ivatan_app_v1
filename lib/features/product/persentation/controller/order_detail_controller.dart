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
        
        // Resolve product details if they are missing titles/images
        if (order.value?.items != null) {
          await _resolveProductDetails(order.value!.items!);
        }
      }
    } catch (e) {
      print('Error fetching order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resolveProductDetails(List<OrderItem> items) async {
    final MarketplaceRepository marketRepo = MarketplaceRepository(apiServices: Get.find<ApiServices>());
    
    for (var item in items) {
      if (item.itemId != null && (item.title == null || item.image == null)) {
        final product = await marketRepo.getProductById(item.itemId.toString());
        if (product != null) {
          item.title = product.title;
          item.image = product.coverImage;
          order.refresh(); // Update UI
        }
      }
    }
  }
}
