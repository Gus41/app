import 'package:uuid/uuid.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/models/comment.dart'; 

final _uuid = Uuid();

class Recipe {
  final String id;
  final String userId;
  final String name;
  final double rating;
  final DateTime dateAdded;
  final Duration preparationTime;
  final List<Ingredient> ingredients;
  final List<StepPreparation> steps;
  
  final List<String> likes;   
  final List<Comment> comments; 

  Recipe({
    String? id,
    required this.userId,
    required this.name,
    required this.rating,
    required this.dateAdded,
    required this.preparationTime,
    required this.ingredients,
    required this.steps,
    List<String>? likes,    
    List<Comment>? comments, 
  })  : id = id ?? _uuid.v4(),
        likes = likes ?? [],
        comments = comments ?? [];

  int get ingredientCount => ingredients.length;

  int get likeCount => likes.length;   

  Recipe copyWith({
    String? id,
    String? userId,
    String? name,
    double? rating,
    DateTime? dateAdded,
    Duration? preparationTime,
    List<Ingredient>? ingredients,
    List<StepPreparation>? steps,
    List<String>? likes,
    List<Comment>? comments,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      dateAdded: dateAdded ?? this.dateAdded,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
