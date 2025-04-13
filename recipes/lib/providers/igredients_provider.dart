import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:recipes/models/ingredients.dart';

class IngredientNotifier extends StateNotifier<List<Ingredient>> {
  IngredientNotifier() : super([]) {
    loadItems();
  }

  Future<sql.Database> _getDb() async {
    final databasePath = await sql.getDatabasesPath();
    return sql.openDatabase(
      join(databasePath, 'ingredients.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ingredients (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            quantity TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> loadItems() async {
    final db = await _getDb();
    final data = await db.query('ingredients');

    final items = data.map((row) {
      return Ingredient(
        id: row['id'] as String,
        name: row['name'] as String,
        quantity: row['quantity'] as String,
      );
    }).toList();
    print("Itens recuperados");
    print(items);
    state = items;
  }

  Future<void> addItem(Ingredient item) async {
    final db = await _getDb();

    await db.insert(
      'ingredients',
      {
        'id': item.id,
        'name': item.name,
        'quantity': item.quantity,
      },
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    print(item);
    print("Adicionado no bd");
    state = [...state, item];
  }

  Future<void> removeItem(String id) async {
    final db = await _getDb();

    state = state.where((e) => e.id != id).toList();

    await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateItem(Ingredient updated) async {
    final db = await _getDb();

    await db.update(
      'ingredients',
      {
        'name': updated.name,
        'quantity': updated.quantity,
      },
      where: 'id = ?',
      whereArgs: [updated.id],
    );

    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }
}
final ingredientProvider = StateNotifierProvider<IngredientNotifier, List<Ingredient>>(
  (ref) => IngredientNotifier(),
);
