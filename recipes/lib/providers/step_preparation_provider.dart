import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:recipes/models/step_preparation.dart';

class StepPreparationNotifier extends StateNotifier<List<StepPreparation>> {
  StepPreparationNotifier() : super([]) {
    loadItems();
  }

  Future<sql.Database> _getDb() async {
    final databasePath = await sql.getDatabasesPath();
    return sql.openDatabase(
      join(databasePath, 'steps.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE steps (
            id TEXT PRIMARY KEY,
            "order" INTEGER NOT NULL,
            instruction TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> loadItems() async {
    final db = await _getDb();
    final data = await db.query('steps');

    final items = data.map((row) => StepPreparation.fromMap(row)).toList();
    print("Itens recuperados");
    print(items);
    state = items;
  }

  Future<void> addItem(StepPreparation item) async {
    final db = await _getDb();

    await db.insert(
      'steps',
      item.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    state = [...state, item];
  }

  Future<void> updateItem(StepPreparation updatedStep) async {
    final db = await _getDb();

    await db.update(
      'steps',
      updatedStep.toMap(),
      where: 'id = ?',
      whereArgs: [updatedStep.id],
    );

    state = [
      for (final step in state)
        if (step.id == updatedStep.id) updatedStep else step
    ];
  }
  Future<void> upsertItem(StepPreparation item) async {
    final db = await _getDb();

    final existing = await db.query(
      'steps',
      where: 'id = ?',
      whereArgs: [item.id],
    );

    if (existing.isEmpty) {
      await addItem(item);
    } else {
      await updateItem(item);
    }
  }
}

final stepPreparationProvider =
    StateNotifierProvider<StepPreparationNotifier, List<StepPreparation>>(
  (ref) => StepPreparationNotifier(),
);
