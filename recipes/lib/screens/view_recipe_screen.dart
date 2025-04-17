import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/screens/form_recipe_screen.dart';
import 'package:recipes/providers/recipe_provider.dart';

class ViewRecipeScreen extends ConsumerWidget {
  const ViewRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as String;
    final recipes = ref.watch(recipeProvider);
    final recipe = recipes.firstWhere((r) => r.id == recipeId);

    final sortedSteps = List<StepPreparation>.from(recipe.steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        title: Text(recipe.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avaliação: ${recipe.rating.toString()}/5',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
                Text(
                  'Tempo de Preparo: ${recipe.preparationTime.inMinutes} min',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
            Container(height: 12),
            Text(
              'Ingredientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...recipe.ingredients.map(
                  (ing) => ListTile(
                contentPadding: EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  ing.name,
                ),
                subtitle: Text(
                  'Quantidade: ${ing.quantity}',
                ),
              ),
            ),
            Container(height: 4),
            Text(
              'Modo de Preparo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...sortedSteps.map(
                  (step) => ListTile(
                contentPadding: EdgeInsets.all(4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  '${step.order}. ${step.instruction}',
                ),
              ),
            ),
            Container(height: 4),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              label: Text('Editar Receita'),
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
    );
  }
}
