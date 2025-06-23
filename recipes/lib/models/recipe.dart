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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'rating': rating,
      'dateAdded': dateAdded.toIso8601String(),
      'preparationTime': preparationTime.inMinutes,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'steps': steps.map((s) => s.toJson()).toList(),
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      rating: (json['rating'] as num).toDouble(),
      dateAdded: DateTime.parse(json['dateAdded']),
      preparationTime: Duration(minutes: json['preparationTime']),
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList(),
      steps: (json['steps'] as List)
          .map((s) => StepPreparation.fromJson(s))
          .toList(),
      likes: List<String>.from(json['likes']),
      comments: (json['comments'] as List)
          .map((c) => Comment.fromJson(c))
          .toList(),
    );
  }
}


