import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/services/DatabaseService.dart';
import 'package:recipes/models/comment.dart';
import 'package:sqflite/sqflite.dart';

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final Ref ref;
  late Database _db;
  bool _initialized = false;

  RecipeNotifier(this.ref) : super([]) {
    _init();
  }

  Future<void> init() async {
    _db = await DatabaseService.openDB();
    await _loadFromDB();
  }

  void addComment(String recipeId, Comment comment) {
    state = [
      for (final recipe in state)
        if (recipe.id == recipeId)
          recipe.copyWith(
            comments: [...recipe.comments, comment],
          )
        else
          recipe,
    ];
  }

  Future<void> _init() async {
    _db = await DatabaseService.openDB();
    await _loadFromDB();
  }

  Future<void> _loadFromDB() async {
    final recipes = await DatabaseService().fetchAllRecipes(_db);
    state = recipes;
  }

  Future<void> addItem(Recipe recipe) async {
    await DatabaseService().insertRecipe(_db, recipe);
    await _loadFromDB();
  }

  Future<void> updateItem(Recipe updatedRecipe) async {
    await DatabaseService().updateRecipe(_db, updatedRecipe);
    await _loadFromDB();
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService().deleteRecipe(_db, id);
    await _loadFromDB();
  }

  Future<void> reload() async {
    await _loadFromDB();
  }

  Future<void> initialize() async {
    if (!_initialized) {
      _db = await DatabaseService.openDB();
      await _loadFromDB();
      _initialized = true;
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    if (!_initialized) {
      await initialize();
    }
    return await DatabaseService().fetchAllRecipes(_db);
  }

  Database get db {
    if (!_initialized) {
      throw Exception('Database not initialized');
    }
    return _db;
  }

  Future<void> closeDB() async {
    await _db.close();
    _initialized = false;
  }

  void toggleLike(String recipeId, String userId) {
    state = [
      for (final recipe in state)
        if (recipe.id == recipeId)
          recipe.copyWith(
            likes: recipe.likes.contains(userId)
                ? (List.of(recipe.likes)..remove(userId))
                : (List.of(recipe.likes)..add(userId)),
          )
        else
          recipe,
    ];
  }
}

final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier(ref);
});

