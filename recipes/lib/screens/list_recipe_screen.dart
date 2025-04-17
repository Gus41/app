import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/routes.dart';
import 'package:recipes/providers/recipe_provider.dart';

class ListRecipeScreen extends ConsumerWidget {
  const ListRecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final recipes = ref.watch(recipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: recipes.isEmpty
          ? const Center(
        child: Text(
          'Sem receitas.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: recipes.length,
        itemBuilder: (ctx, i) {
          final recipe = recipes[i];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.viewRecipe,
                arguments: recipe.id,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${recipe.ingredientCount} ingredientes | ${recipe.preparationTime.inMinutes} min',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.formRecipe);
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}