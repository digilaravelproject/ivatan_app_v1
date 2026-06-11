import 'package:i_vatan_app/core/network/api_services.dart';
import 'package:i_vatan_app/core/network/app_urls.dart';
import '../model/marketplace_product_model.dart';

class MarketplaceRepository {
  final ApiServices apiServices;

  MarketplaceRepository({required this.apiServices});

  Future<MarketplaceProductResponse?> getMarketplaceProducts({
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await apiServices.callGet(
        AppUrls.marketplaceProducts,
        queryParams: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      if (response != null && response['success'] == true) {
        return MarketplaceProductResponse.fromJson(response['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error fetching marketplace products: $e');
      return null;
    }
  }
  Future<MarketplaceProduct?> getProductById(String id) async {
    try {
      final response = await apiServices.callGet(AppUrls.marketplaceProductDetailItem(id));
      if (response != null && response['success'] == true) {
        return MarketplaceProduct.fromJson(response['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error fetching product by id: $e');
      return null;
    }
  }
}
