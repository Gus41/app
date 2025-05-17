import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/routes.dart';
import 'package:recipes/screens/list_recipe_screen.dart';
import 'package:recipes/screens/view_recipe_screen.dart';
import 'TestApiScreen.dart';
import 'screens/form_ingredient_screen.dart';
import 'screens/form_recipe_screen.dart';
import 'screens/form_step_screen.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.testApi,
      routes: {
        AppRoutes.listRecipes: (ctx) => const ListRecipeScreen(),
        AppRoutes.viewRecipe: (ctx) => const ViewRecipeScreen(),
        AppRoutes.formRecipe: (ctx) => const FormRecipeScreen(),
        AppRoutes.formIngredient: (ctx) => const FormIngredientScreen(),
        AppRoutes.formStep: (ctx) => const FormStepScreen(),
        AppRoutes.testApi: (ctx) => const TestApiScreen(),
      },
    );
  }
}
