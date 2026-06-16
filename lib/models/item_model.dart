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
}
