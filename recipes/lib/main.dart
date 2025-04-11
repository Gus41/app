import 'package:flutter/material.dart';
import 'package:recipes/routes.dart';
import 'package:recipes/screens/list_recipe_screen.dart';
import 'package:recipes/screens/view_recipe_screen.dart';

import 'screens/form_ingredient_screen.dart';
import 'screens/form_recipe_screen.dart';
import 'screens/form_step_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receitas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.listRecipes,
      routes: {
        AppRoutes.listRecipes: (ctx) => const ListRecipeScreen(),
        AppRoutes.viewRecipe: (ctx) => const ViewRecipeScreen(),
        AppRoutes.formRecipe: (ctx) => const FormRecipeScreen(),
        AppRoutes.formIngredient: (ctx) => const FormIngredientScreen(),
        AppRoutes.formStep: (ctx) => const FormStepScreen(),
      },
    );
  }
}
