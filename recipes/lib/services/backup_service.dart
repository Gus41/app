  import 'dart:convert';
  import 'dart:io';
  import 'package:path_provider/path_provider.dart';
  import 'package:recipes/services/database_service.dart';
  import 'package:recipes/models/recipe.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'dart:isolate';
  import 'package:sqflite/sqflite.dart';
  import 'package:path/path.dart';

  class BackupService {
    static Future<void> gerarBackupJson(List<dynamic> recipes) async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backup_recipes.json');

      final data = recipes.map((r) => r.toJson()).toList();
      await file.writeAsString(json.encode(data));

      print('Backup salvo em: ${file.path}');
    }

    static Future<void> gerarBackupFirestore(List<dynamic> recipes) async {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final recipesRef = firestore.collection('recipes_backup');

      print('Iniciando backup Firestore...');
      final snapshot = await recipesRef.get();
      print('Encontrados ${snapshot.docs.length} documentos para deletar.');
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      for (var recipe in recipes) {
        final data = recipe.toJson();
        batch.set(recipesRef.doc(recipe.id), data);
        print('Preparando inserção da receita: ${recipe.name}');
      }

      await batch.commit();
      print('Backup Firestore concluído');
    }

    static Future<List<Recipe>> restoreDataFirestore() async {
      try {
        final snapshot = await FirebaseFirestore.instance.collection(
            'recipes_backup').get();

        final recipes = snapshot.docs.map((doc) {
          final data = doc.data();
          return Recipe.fromJson(Map<String, dynamic>.from(data));
        }).toList();

        final db = await DatabaseService.openDB();
        await DatabaseService().replaceAllRecipes(db, recipes);

        print('Restauração do Firestore concluída, dados inseridos no banco.');
        return recipes;
      } catch (e) {
        print('Erro no restaurarDoFirestore: $e');
        return [];
      }
    }

    static Future<List<Recipe>> restoreData() async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/backup_recipes.json');
        final jsonString = await file.readAsString();
        final List<dynamic> dataList = json.decode(jsonString);

        final recipes = dataList
            .map((json) => Recipe.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final db = await DatabaseService.openDB();
        await DatabaseService().replaceAllRecipes(db, recipes);

        print('Restauração concluída, dados inseridos no banco.');
        return recipes;
      } catch (e) {
        print('Erro no restoreData: $e');
        return [];
      }
    }

    static Future<void> restaurarComIsolate() async {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/backup_recipes.json';

      final receivePort = ReceivePort();

      await Isolate.spawn<_ParseParams>(
        _parseJsonWorker,
        _ParseParams(receivePort.sendPort, filePath),
      );

      // Espera o resultado do isolate
      final result = await receivePort.first;

      if (result is List<Recipe>) {
        print('Isolate processou o JSON, inserindo no banco...');
        final db = await DatabaseService.openDB();
        await DatabaseService().replaceAllRecipes(db, result);
        await db.close();
        print('Restauração concluída com sucesso');
      } else if (result is String) {
        print('Erro no Isolate: $result');
      }
    }

    static void _parseJsonWorker(_ParseParams params) async {
      try {
        final file = File(params.filePath);
        final jsonString = await file.readAsString();
        final List<dynamic> dataList = json.decode(jsonString);

        final recipes = dataList
            .map((json) => Recipe.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        params.sendPort.send(recipes);
      } catch (e) {
        params.sendPort.send(e.toString());
      }
    }
  }

    class _ParseParams {
    final SendPort sendPort;
    final String filePath;

    _ParseParams(this.sendPort, this.filePath);
    }