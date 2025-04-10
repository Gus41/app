import 'package:uuid/uuid.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';

final _uuid = Uuid();

class Recipe {
  final String id;
  final String name;
  final double rating;
  final DateTime dateAdded;
  final Duration preparationTime;
  final List<Ingredient> ingredients;
  final List<StepPreparation> steps;

  Recipe({
    String? id,
    required this.name,
    required this.rating,
    required this.dateAdded,
    required this.preparationTime,
    required this.ingredients,
    required this.steps,
  }) : id = id ?? _uuid.v4();

  int get ingredientCount => ingredients.length;
  int get stepCount => steps.length;
}
