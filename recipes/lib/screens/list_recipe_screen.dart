import 'package:flutter/material.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/routes.dart';

class ListRecipeScreen extends StatelessWidget {
  const ListRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = <Recipe>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Receitas'),
      ),
      body: recipes.isEmpty
          ? const Center(child: Text('Nenhuma receita cadastrada.'))
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (ctx, i) {
          final recipe = recipes[i];
          return ListTile(
            title: Text(recipe.name),
            subtitle: Text(
                '${recipe.ingredientCount} ingredientes • ${recipe.stepCount} passos'),
            trailing: Text(
              '${recipe.preparationTime.inMinutes} min',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.viewRecipe,
                arguments: recipe,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.formRecipe);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
