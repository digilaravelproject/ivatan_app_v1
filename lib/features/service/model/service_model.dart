class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String duration; // e.g., "1 hour", "2 days"
  final List<String> images;
  final bool isActive;
  final String userId;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.images,
    this.isActive = true,
    required this.userId,
  });
}
