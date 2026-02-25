import 'package:get/get.dart';
import '../model/service_model.dart';

class ServiceController extends GetxController {
  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleServices();
  }

  void loadSampleServices() {
    // Sample services data
    services.value = [
      ServiceModel(
        id: '1',
        title: 'Web Development',
        description: 'Professional website development with modern technologies',
        category: 'Development',
        price: 5000,
        duration: '2 weeks',
        images: ['https://m.media-amazon.com/images/I/71vFKBpKakL._AC_UF894,1000_QL80_.jpg'],
        isActive: true,
        userId: 'user1',
      ),
      ServiceModel(
        id: '2',
        title: 'Graphic Design',
        description: 'Creative graphic design for your brand',
        category: 'Design',
        price: 2000,
        duration: '3 days',
        images: ['https://m.media-amazon.com/images/I/71vFKBpKakL._AC_UF894,1000_QL80_.jpg'],
        isActive: true,
        userId: 'user1',
      ),
      ServiceModel(
        id: '3',
        title: 'Digital Marketing',
        description: 'Complete digital marketing solutions',
        category: 'Marketing',
        price: 8000,
        duration: '1 month',
        images: ['https://m.media-amazon.com/images/I/71vFKBpKakL._AC_UF894,1000_QL80_.jpg'],
        isActive: true,
        userId: 'user1',
      ),
    ];
  }

  void addService(ServiceModel service) {
    services.add(service);
  }

  void updateService(String id, ServiceModel updatedService) {
    final index = services.indexWhere((s) => s.id == id);
    if (index != -1) {
      services[index] = updatedService;
      services.refresh();
    }
  }

  void deleteService(String id) {
    services.removeWhere((s) => s.id == id);
  }

  void toggleServiceStatus(String id) {
    final index = services.indexWhere((s) => s.id == id);
    if (index != -1) {
      final service = services[index];
      services[index] = ServiceModel(
        id: service.id,
        title: service.title,
        description: service.description,
        category: service.category,
        price: service.price,
        duration: service.duration,
        images: service.images,
        isActive: !service.isActive,
        userId: service.userId,
      );
      services.refresh();
    }
  }
}
