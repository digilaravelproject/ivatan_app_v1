class ReadReceiptReader {
  final int id;
  final String name;
  final String avatar;

  ReadReceiptReader({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ReadReceiptReader.fromJson(Map<String, dynamic> json) {
    return ReadReceiptReader(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
