import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:recipes/models/step_preparation.dart';


class StepPreparationNotifier extends StateNotifier<List<StepPreparation>> {
  StepPreparationNotifier() : super([]) {
    _loadItems();
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

  Future<void> _loadItems() async {
    final db = await _getDb();
    final data = await db.query('steps');

    final items = data.map((row) => StepPreparation.fromMap(row)).toList();

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

  Future<void> removeItem(String id) async {
    final db = await _getDb();

    await db.delete(
      'steps',
      where: 'id = ?',
      whereArgs: [id],
    );

    state = state.where((step) => step.id != id).toList();
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
}
final stepPreparationProvider =
    StateNotifierProvider<StepPreparationNotifier, List<StepPreparation>>(
  (ref) => StepPreparationNotifier(),
);

