import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/screens/form_recipe_screen.dart';
import 'package:recipes/providers/recipe_provider.dart';
import 'package:recipes/widgets/chatModal.dart';

class ViewRecipeScreen extends ConsumerWidget {
  const ViewRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as String;
    final recipes = ref.watch(recipeProvider);
    final recipe = recipes.firstWhere((r) => r.id == recipeId);

    final sortedSteps = List<StepPreparation>.from(recipe.steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    final backgroundColor = const Color(0xFF1C1C1C);
    final primaryRed = Colors.redAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        title: Text(recipe.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(recipeProvider.notifier).deleteItem(recipe.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.rating.toString()}/5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ]),
                Row(children: [
                  const Icon(Icons.timer, color: Colors.white70, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.preparationTime.inMinutes} min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text(
              'Ingredientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ing) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.restaurant_menu, color: Colors.white70),
                  title: Text(
                    ing.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Quantidade: ${ing.quantity}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text(
              'Modo de Preparo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...sortedSteps.map(
              (step) => Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.format_list_numbered, color: Colors.white70),
                  title: Text(
                    '${step.order}. ${step.instruction}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit, color: Colors.white,),
              label: const Text('Editar Receita'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FormRecipeScreen(recipe: recipe),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryRed,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const ChatModal(),
          );
        },
      ),
    );
  }
}
