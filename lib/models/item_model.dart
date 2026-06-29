class OrderItem {
  final String id;
  String name;
  double price;
  String assignedTo; // member name

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assignedTo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'assignedTo': assignedTo,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        assignedTo: json['assignedTo'] ?? '',
      );
}
