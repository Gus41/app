import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes/routes.dart';
import 'package:recipes/screens/list_recipe_screen.dart';
import 'package:recipes/screens/login_screen.dart';
import 'package:recipes/screens/view_recipe_screen.dart';
import 'screens/form_ingredient_screen.dart';
import 'screens/form_recipe_screen.dart';
import 'screens/form_step_screen.dart';
import 'package:recipes/providers/auth_provider.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseFirestore.instance
    .collection('test')
    .doc('abc123')
    .set({'test': 'value'});

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    print(authState.user);

    final initialScreen = authState.user != null
        ? const ListRecipeScreen()
        : const AuthScreen();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialScreen,  
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
