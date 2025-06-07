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

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'instruction': instruction,
      };

  factory StepPreparation.fromJson(Map<String, dynamic> json) => StepPreparation(
        id: json['id'],
        order: json['order'],
        instruction: json['instruction'],
      );
}
