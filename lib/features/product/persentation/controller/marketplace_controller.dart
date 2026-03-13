import 'package:get/get.dart';
import 'package:i_vatan_app/core/network/api_services.dart';
import '../../data/model/marketplace_product_model.dart';
import '../../data/repository/marketplace_repository.dart';

class MarketplaceController extends GetxController {
  late MarketplaceRepository repository;
  
  var products = <MarketplaceProduct>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final apiServices = Get.find<ApiServices>();
    repository = MarketplaceRepository(apiServices: apiServices);
    fetchMarketplaceProducts();
  }

  Future<void> fetchMarketplaceProducts({int page = 1}) async {
    if (page == 1) {
      isLoading.value = true;
    }

    try {
      final response = await repository.getMarketplaceProducts(page: page);

      if (response != null) {
        if (page == 1) {
          products.value = response.products;
        } else {
          products.addAll(response.products);
        }

        currentPage.value = response.currentPage;
        lastPage.value = response.lastPage;
        total.value = response.total;
      }
    } catch (e) {
      print('Error in marketplace controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (currentPage.value < lastPage.value) {
      await fetchMarketplaceProducts(page: currentPage.value + 1);
    }
  }

  void refreshProducts() {
    currentPage.value = 1;
    products.clear();
    fetchMarketplaceProducts();
  }
}
