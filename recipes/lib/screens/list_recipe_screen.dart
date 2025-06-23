  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:recipes/routes.dart';
  import 'package:recipes/providers/recipe_provider.dart';
  import 'package:recipes/providers/auth_provider.dart';
  import 'package:recipes/services/backup_service.dart';
  import 'package:recipes/services/database_service.dart';
  import 'package:recipes/services/notification_service.dart';

  class ListRecipeScreen extends ConsumerWidget {
    const ListRecipeScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final recipes = ref.watch(recipeProvider);
      final recipeNotifier = ref.read(recipeProvider.notifier);
      final authState = ref.watch(authProvider);
      final userId = authState.user?.uid ?? '';

      const backgroundColor = Color(0xFF121212);
      const cardColor = Color(0xFF1E1E1E);
      const accentColor = Color(0xFFFF1744);

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Minhas Receitas'),
              SizedBox(width: 8),
              Icon(Icons.restaurant_menu_rounded),
            ],
          ),
          centerTitle: true,
          backgroundColor: backgroundColor,
          foregroundColor: accentColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: 'Backup / Restaurar',
              onPressed: () {
                mostrarDialogoBackupRestore(context, ref);
              },
            )
          ],
        ),

        backgroundColor: backgroundColor,
        body: recipes.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.no_food, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Sem receitas cadastradas.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: recipes.length,
                itemBuilder: (ctx, i) {
                  final recipe = recipes[i];
                  final isLiked = recipe.likes.contains(userId);

                  return Card(
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.viewRecipe,
                          arguments: recipe.id,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título e ícone
                            Row(
                              children: [
                                const Icon(Icons.restaurant, color: accentColor, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // TEM QUE MUDAR COISA AQUI EM
                            //TODO: ALTER THE USERNAME HERE AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                            Text(
                              'Por: ${recipe.userId}',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Informações ingredientes e tempo
                            Row(
                              children: [
                                const Icon(Icons.kitchen, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '${recipe.ingredientCount} ingredientes',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Icon(Icons.timer, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '${recipe.preparationTime.inMinutes} min',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Linha de like
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${recipe.likes.length}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: accentColor,
                                  ),
                                  onPressed: () {
                                    recipeNotifier.toggleLike(recipe.id, userId);
                                  },
                                  tooltip: isLiked ? 'Descurtir' : 'Curtir',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.formRecipe);
          },
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Nova Receita',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    Future<void> mostrarDialogoBackupRestore(BuildContext context, WidgetRef ref) async {
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Escolha a ação'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'backup_file'),
              child: const Text('Backup para arquivo'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'backup_firestore'),
              child: const Text('Backup para Firestore'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'restore_file'),
              child: const Text('Restaurar de arquivo'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'restore_firestore'),
              child: const Text('Restaurar do Firestore'),
            ),
          ],
        ),
      );

      final provider = ref.read(recipeProvider.notifier);
      await provider.initialize();

      final recipes = await provider.getAllRecipes();

      if (choice == 'backup_file') {
        try {
          await BackupService.gerarBackupJson(recipes);
          await NotificationService.show(
            title: 'Backup concluído',
            body: 'Backup em arquivo salvo com sucesso!',
          );
        } catch (e) {
          await NotificationService.show(
            title: 'Erro no backup',
            body: 'Ocorreu um erro ao salvar o backup no arquivo.',
          );
        }

      } else if (choice == 'backup_firestore') {
        final provider = ref.read(recipeProvider.notifier);
        await provider.initialize();
        final recipes = await provider.getAllRecipes();
        try {
          await BackupService.gerarBackupFirestore(recipes);
          print('Backup Firestore realizado com sucesso!');
          await NotificationService.show(
            title: 'Backup concluído',
            body: 'Backup no Firestore salvo com sucesso!',
          );
        } catch (e) {
          print('Erro no backup Firestore: $e');
          await NotificationService.show(
            title: 'Erro no backup',
            body: 'Ocorreu um erro ao salvar o backup no Firestore.',
          );
        }

      } else if (choice == 'restore_file') {
        try {
          await provider.closeDB();
          await BackupService.restaurarComIsolate();
          await provider.initialize();
          await provider.reload();
          await NotificationService.show(
            title: 'Restauração concluída',
            body: 'Restauração do arquivo realizada com sucesso!',
          );
        } catch (e) {
          await NotificationService.show(
            title: 'Erro na restauração',
            body: 'Ocorreu um erro ao restaurar do arquivo.',
          );
        }

      } else if (choice == 'restore_firestore') {
        try {
          final restored = await BackupService.restoreDataFirestore();
          await DatabaseService().replaceAllRecipes(provider.db, restored);
          await provider.reload();
          await NotificationService.show(
            title: 'Restauração concluída',
            body: 'Restauração do Firestore realizada com sucesso!',
          );
        } catch (e) {
          await NotificationService.show(
            title: 'Erro na restauração',
            body: 'Ocorreu um erro ao restaurar do Firestore.',
          );
        }
      }
    }
  }