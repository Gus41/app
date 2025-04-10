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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'quantity': quantity,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        id: map['id'],
        name: map['name'],
        quantity: map['quantity'],
      );
}
