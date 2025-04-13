import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class StepPreparation {
  final String id;
  final int order;
  final String instruction;

  StepPreparation({
    String? id,
    required this.order,
    required this.instruction,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'order': order,
        'instruction': instruction,
      };

  factory StepPreparation.fromMap(Map<String, dynamic> map) => StepPreparation(
        id: map['id'],
        order: map['order'],
        instruction: map['instruction'],
      );
}
