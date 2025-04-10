import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/recipe.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sql;

//providers
import 'package:recipes/providers/igredients_provider.dart';
import 'package:recipes/providers/step_preparation_provider.dart';

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final Ref ref;

  RecipeNotifier(this.ref) : super([]) {
    _loadItems();
  }

  Future<sql.Database> _getDb() async {
    final databasePath = await sql.getDatabasesPath();
    return sql.openDatabase(
      join(databasePath, 'recipes.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            rating REAL NOT NULL,
            dateAdded TEXT NOT NULL,
            preparationTime INTEGER NOT NULL,
            ingredientIds TEXT NOT NULL,
            stepIds TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> _loadItems() async {
    final db = await _getDb();
    final data = await db.query('recipes');

    //reading data of providers
    final ingredientList = ref.read(ingredientProvider);
    final stepList = ref.read(stepPreparationProvider);

    final items = data.map((row) {
      final ingredientIds =
          List<String>.from(jsonDecode(row['ingredientIds'] as String));
      final stepIds = List<String>.from(jsonDecode(row['stepIds'] as String));

      final ingredients =
          ingredientList.where((i) => ingredientIds.contains(i.id)).toList();
      final steps = stepList.where((s) => stepIds.contains(s.id)).toList();

      return Recipe(
        id: row['id'] as String,
        name: row['name'] as String,
        rating: row['rating'] as double,
        dateAdded: DateTime.parse(row['dateAdded'] as String),
        preparationTime: Duration(minutes: row['preparationTime'] as int),
        ingredients: ingredients,
        steps: steps,
      );
    }).toList();

    state = items;
  }

  Future<void> addItem(Recipe item) async {
    final db = await _getDb();

    await db.insert(
      'recipes',
      {
        'id': item.id,
        'name': item.name,
        'rating': item.rating,
        'dateAdded': item.dateAdded.toIso8601String(),
        'preparationTime': item.preparationTime.inMinutes,
        'ingredientIds': jsonEncode(item.ingredients.map((e) => e.id).toList()),
        'stepIds': jsonEncode(item.steps.map((e) => e.id).toList()),
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    //TODO: use provider to add of db igredients and steps

    state = [...state, item];
  }

  Future<void> removeItem(String id) async {
    final db = await _getDb();

    state = state.where((r) => r.id != id).toList();

    await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    //TODO: use provider to remove of db igredients and steps IF WAS UPDATED
  }

  Future<void> updateItem(Recipe updatedRecipe) async {
    final db = await _getDb();

    await db.update(
      'recipes',
      {
        'name': updatedRecipe.name,
        'rating': updatedRecipe.rating,
        'dateAdded': updatedRecipe.dateAdded.toIso8601String(),
        'preparationTime': updatedRecipe.preparationTime.inMinutes,
        'ingredientIds':
            jsonEncode(updatedRecipe.ingredients.map((i) => i.id).toList()),
        'stepIds': jsonEncode(updatedRecipe.steps.map((s) => s.id).toList()),
      },
      where: 'id = ?',
      whereArgs: [updatedRecipe.id],
    );

      //TODO: use provider to update db of igredients and steps IF WAS UPDATED

    state = [
      for (final recipe in state)
        if (recipe.id == updatedRecipe.id) updatedRecipe else recipe,
    ];
  }
}

final recipeProvider =
    StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier(ref);
});
