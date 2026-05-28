class GuestModel {
  final int id;
  final String name;
  final String description;
  int qty;
  final double price;

  GuestModel({
    required this.id,
    required this.name,
    required this.description,
    required this.qty,
    required this.price,
  });

  factory GuestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GuestModel(
      id: json["id"] ?? 0,

      name: json["name"] ?? '',

      description:
          json["description"] ?? '',

      qty: json["qty"] ?? 0,

      price: double.tryParse(
            json["price"].toString(),
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "qty": qty,
      "price": price,
    };
  }
}