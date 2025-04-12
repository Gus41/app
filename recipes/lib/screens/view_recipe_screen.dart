import 'package:flutter/material.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/screens/form_recipe_screen.dart';

class ViewRecipeScreen extends StatelessWidget {
  const ViewRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipe = ModalRoute.of(context)!.settings.arguments as Recipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Avaliação: ${recipe.rating.toStringAsFixed(1)} ⭐',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tempo de preparo: ${recipe.preparationTime.inMinutes} minutos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Ingredientes:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
                  (ing) => ListTile(
                title: Text(ing.name),
                subtitle: Text(ing.quantity),
                leading: const Icon(Icons.kitchen_outlined),
              ),
            ),
            const Divider(height: 32),
            Text(
              'Modo de preparo:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...recipe.steps.map(
                  (step) => ListTile(
                leading: CircleAvatar(
                  child: Text(step.order.toString()),
                ),
                title: Text(step.instruction),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar Receita'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FormRecipeScreen(recipe: recipe,),
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
