import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/models/comment.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';

class DatabaseService {
  static Future<Database> openDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recipes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id TEXT PRIMARY KEY,
            userId TEXT,
            name TEXT,
            rating REAL,
            dateAdded TEXT,
            preparationTime INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE ingredients (
            id TEXT PRIMARY KEY,
            recipeId TEXT,
            name TEXT,
            quantity TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE steps (
            id TEXT PRIMARY KEY,
            recipeId TEXT,
            stepOrder INTEGER,
            instruction TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE comments (
            id TEXT PRIMARY KEY,
            recipeId TEXT,
            userId TEXT,
            username TEXT,
            text TEXT,
            timestamp TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE likes (
            recipeId TEXT,
            userId TEXT,
            PRIMARY KEY(recipeId, userId)
          )
        ''');

        print('Banco de dados e tabelas criados');
      },
    );
  }

  Future<void> insertRecipe(DatabaseExecutor executor, Recipe recipe) async {

    await executor.insert('recipes', {
      'id': recipe.id,
      'userId': recipe.userId,
      'name': recipe.name,
      'rating': recipe.rating,
      'dateAdded': recipe.dateAdded.toIso8601String(),
      'preparationTime': recipe.preparationTime.inMinutes,
    });

    for (var ingredient in recipe.ingredients) {
      await executor.insert('ingredients', {
        'id': ingredient.id,
        'recipeId': recipe.id,
        'name': ingredient.name,
        'quantity': ingredient.quantity,
      });
    }

    for (var step in recipe.steps) {
      await executor.insert('steps', {
        'id': step.id,
        'recipeId': recipe.id,
        'stepOrder': step.order,
        'instruction': step.instruction,
      });
    }

    for (var userId in recipe.likes) {
      await executor.insert('likes', {
        'recipeId': recipe.id,
        'userId': userId,
      });
    }

    for (var comment in recipe.comments) {
      await executor.insert('comments', {
        'id': comment.id,
        'recipeId': recipe.id,
        'userId': comment.userId,
        'username': comment.username,
        'text': comment.text,
        'timestamp': comment.timestamp.toIso8601String(),
      });
    }
  }

  Future<void> updateRecipe(Database db, Recipe recipe) async {
    await db.transaction((txn) async {
      await txn.update(
        'recipes',
        {
          'userId': recipe.userId,
          'name': recipe.name,
          'rating': recipe.rating,
          'dateAdded': recipe.dateAdded.toIso8601String(),
          'preparationTime': recipe.preparationTime.inMinutes,
        },
        where: 'id = ?',
        whereArgs: [recipe.id],
      );

      await txn.delete('ingredients', where: 'recipeId = ?', whereArgs: [recipe.id]);
      await txn.delete('steps', where: 'recipeId = ?', whereArgs: [recipe.id]);
      await txn.delete('likes', where: 'recipeId = ?', whereArgs: [recipe.id]);
      await txn.delete('comments', where: 'recipeId = ?', whereArgs: [recipe.id]);

      for (var ingredient in recipe.ingredients) {
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'recipeId': recipe.id,
          'name': ingredient.name,
          'quantity': ingredient.quantity,
        });
      }

      for (var step in recipe.steps) {
        await txn.insert('steps', {
          'id': step.id,
          'recipeId': recipe.id,
          'stepOrder': step.order,
          'instruction': step.instruction,
        });
      }

      for (var userId in recipe.likes) {
        await txn.insert('likes', {
          'recipeId': recipe.id,
          'userId': userId,
        });
      }

      for (var comment in recipe.comments) {
        await txn.insert('comments', {
          'id': comment.id,
          'recipeId': recipe.id,
          'userId': comment.userId,
          'username': comment.username,
          'text': comment.text,
          'timestamp': comment.timestamp.toIso8601String(),
        });
      }
    });
  }

  Future<void> deleteRecipe(Database db, String id) async {
    await db.transaction((txn) async {
      await txn.delete('ingredients', where: 'recipeId = ?', whereArgs: [id]);
      await txn.delete('steps', where: 'recipeId = ?', whereArgs: [id]);
      await txn.delete('likes', where: 'recipeId = ?', whereArgs: [id]);
      await txn.delete('comments', where: 'recipeId = ?', whereArgs: [id]);
      await txn.delete('recipes', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> replaceAllRecipes(Database db, List<Recipe> recipes) async {
    await db.transaction((txn) async {
      await txn.delete('ingredients');
      await txn.delete('steps');
      await txn.delete('likes');
      await txn.delete('comments');
      await txn.delete('recipes');

      for (var recipe in recipes) {
        await insertRecipe(txn, recipe);
      }
    });
  }

  Future<List<Recipe>> fetchAllRecipes(Database db) async {
    final recipesMapList = await db.query('recipes');
    List<Recipe> recipes = [];

    for (var recipeMap in recipesMapList) {
      final recipeId = recipeMap['id'] as String;

      final ingredientsMapList = await db.query(
        'ingredients',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );
      final ingredients = ingredientsMapList
          .map((map) => Ingredient.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      final stepsMapList = await db.query(
        'steps',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );
      final steps = stepsMapList
          .map((map) => StepPreparation.fromJson({
        'id': map['id'],
        'order': map['stepOrder'],
        'instruction': map['instruction'],
      }))
          .toList();

      final likesMapList = await db.query(
        'likes',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );
      final likes = likesMapList.map((map) => map['userId'] as String).toList();

      final commentsMapList = await db.query(
        'comments',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );
      final comments = commentsMapList
          .map((map) => Comment.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      recipes.add(Recipe(
        id: recipeId,
        userId: recipeMap['userId'] as String,
        name: recipeMap['name'] as String,
        rating: (recipeMap['rating'] as num).toDouble(),
        dateAdded: DateTime.parse(recipeMap['dateAdded'] as String),
        preparationTime: Duration(minutes: recipeMap['preparationTime'] as int),
        ingredients: ingredients,
        steps: steps,
        likes: likes,
        comments: comments,
      ));
    }

    return recipes;
  }
}