import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Ingredient {
  final String id;
  final String name;
  final String quantity;

  Ingredient({
    String? id,
    required this.name,
    required this.quantity,
  }) : id = id ?? _uuid.v4();

    Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity']
  );
}
