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

   Recipe copyWith({
    String? id,
    String? name,
    double? rating,
    DateTime? dateAdded,
    Duration? preparationTime,
    List<Ingredient>? ingredients,
    List<StepPreparation>? steps,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      dateAdded: dateAdded ?? this.dateAdded,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
    );
  }
}
