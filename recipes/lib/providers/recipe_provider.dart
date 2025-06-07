import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final Ref ref;

  RecipeNotifier(this.ref) : super([]) {
    _loadItems();
  }

  final _recipesCollection = FirebaseFirestore.instance.collection('recipes');

  Future<void> _loadItems() async {
    final querySnapshot = await _recipesCollection.get();

    final items = querySnapshot.docs.map((doc) {
      final data = doc.data();

      final ingredients = (data['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final steps = (data['steps'] as List<dynamic>)
          .map((e) => StepPreparation.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final likes = List<String>.from(data['likes'] ?? []);

      final comments = (data['comments'] as List<dynamic>? ?? [])
          .map((e) => Comment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return Recipe(
        id: data['id'],
        userId: data['userId'],
        name: data['name'],
        rating: (data['rating'] as num).toDouble(),
        dateAdded: DateTime.parse(data['dateAdded']),
        preparationTime: Duration(minutes: data['preparationTime']),
        ingredients: ingredients,
        steps: steps,
        likes: likes,
        comments: comments,
      );
    }).toList();

    state = items;
  }

  Future<void> addItem(Recipe item) async {
    final sortedSteps = List<StepPreparation>.from(item.steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    await _recipesCollection.doc(item.id).set({
      'id': item.id,
      'userId': item.userId,
      'name': item.name,
      'rating': item.rating,
      'dateAdded': item.dateAdded.toIso8601String(),
      'preparationTime': item.preparationTime.inMinutes,
      'ingredients': item.ingredients.map((e) => e.toJson()).toList(),
      'steps': sortedSteps.map((e) => e.toJson()).toList(),
      'likes': item.likes,
      'comments': item.comments.map((e) => e.toJson()).toList(),
    });

    state = [...state, item.copyWith(steps: sortedSteps)];
  }

  Future<void> deleteItem(String id) async {
    await _recipesCollection.doc(id).delete();
    state = state.where((recipe) => recipe.id != id).toList();
  }

  Future<void> updateItem(Recipe updatedRecipe) async {
    final sortedSteps = List<StepPreparation>.from(updatedRecipe.steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    await _recipesCollection.doc(updatedRecipe.id).update({
      'userId': updatedRecipe.userId,
      'name': updatedRecipe.name,
      'rating': updatedRecipe.rating,
      'dateAdded': updatedRecipe.dateAdded.toIso8601String(),
      'preparationTime': updatedRecipe.preparationTime.inMinutes,
      'ingredients': updatedRecipe.ingredients.map((e) => e.toJson()).toList(),
      'steps': sortedSteps.map((e) => e.toJson()).toList(),
      'likes': updatedRecipe.likes,
      'comments': updatedRecipe.comments.map((e) => e.toJson()).toList(),
    });

    final updatedWithSortedSteps = updatedRecipe.copyWith(steps: sortedSteps);

    state = [
      for (final recipe in state)
        if (recipe.id == updatedRecipe.id) updatedWithSortedSteps else recipe,
    ];
  }

  Future<void> toggleLike(String recipeId, String userId) async {
    final recipe = state.firstWhere((r) => r.id == recipeId);

    final updatedLikes = recipe.likes.contains(userId)
        ? recipe.likes.where((id) => id != userId).toList()
        : [...recipe.likes, userId];

    final updatedRecipe = recipe.copyWith(likes: updatedLikes);

    await _recipesCollection.doc(recipeId).update({
      'likes': updatedLikes,
    });

    state = [
      for (final r in state) if (r.id == recipeId) updatedRecipe else r,
    ];
  }

  Future<void> addComment(String recipeId, Comment comment) async {
    final recipe = state.firstWhere((r) => r.id == recipeId);

    final updatedComments = [...recipe.comments, comment];

    final updatedRecipe = recipe.copyWith(comments: updatedComments);

    await _recipesCollection.doc(recipeId).update({
      'comments': updatedComments.map((c) => c.toJson()).toList(),
    });

    state = [
      for (final r in state) if (r.id == recipeId) updatedRecipe else r,
    ];
  }
}

final recipeProvider =
    StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier(ref);
});
