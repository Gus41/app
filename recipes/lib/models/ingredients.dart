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
}
