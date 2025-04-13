import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/providers/recipe_provider.dart';
import 'package:recipes/screens/form_ingredient_screen.dart';
import 'package:recipes/screens/form_step_screen.dart';

class FormRecipeScreen extends ConsumerStatefulWidget {
  const FormRecipeScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  ConsumerState<FormRecipeScreen> createState() => _FormRecipeScreenState();
}

class _FormRecipeScreenState extends ConsumerState<FormRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _timeController = TextEditingController();

  final _ingredients = <Ingredient>[];
  final _steps = <StepPreparation>[];

  String _name = '';
  double _rating = 0.0;
  Duration _preparationTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      final recipe = widget.recipe!;
      _name = recipe.name;
      _rating = recipe.rating;
      _preparationTime = recipe.preparationTime;
      _ingredients.addAll(recipe.ingredients);
      _steps.addAll(recipe.steps);

      _nameController.text = _name;
      _ratingController.text = _rating.toString();
      _timeController.text = _preparationTime.inMinutes.toString();
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isEditing = widget.recipe != null;
      final id = isEditing ? widget.recipe!.id : const Uuid().v4();

      final newRecipe = Recipe(
        id: id,
        name: _name,
        rating: _rating,
        dateAdded: DateTime.now(),
        preparationTime: _preparationTime,
        ingredients: _ingredients,
        steps: _steps,
      );

      final notifier = ref.read(recipeProvider.notifier);

      if (isEditing) {
        notifier.updateItem(newRecipe);
      } else {
        notifier.addItem(newRecipe);
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> _addIngredient() async {
    final result = await Navigator.of(context).push<Ingredient>(
      MaterialPageRoute(builder: (_) => const FormIngredientScreen()),
    );

    if (result != null) {
      setState(() => _ingredients.add(result));
    }
  }

  Future<void> _addStep() async {
    final result = await Navigator.of(context).push<StepPreparation>(
      MaterialPageRoute(builder: (_) => const FormStepScreen()),
    );

    if (result != null) {
      setState(() => _steps.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Receita' : 'Nova Receita'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Receita',
                  labelStyle: TextStyle(color: Colors.red),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Informe um nome.'
                    : null,
              ),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(
                  labelText: 'Avaliação (0-5)',
                  labelStyle: TextStyle(color: Colors.red),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) =>
                    _rating = double.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  final rating = double.tryParse(value ?? '');
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Avaliação deve estar entre 0 e 5.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Tempo de Preparo (min)',
                  labelStyle: TextStyle(color: Colors.red),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _preparationTime =
                    Duration(minutes: int.tryParse(value ?? '0') ?? 0),
                validator: (value) {
                  final minutes = int.tryParse(value ?? '');
                  if (minutes == null || minutes < 0) {
                    return 'Informe um tempo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar Ingrediente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ..._ingredients.map((i) => ListTile(
                    title: Text(i.name),
                    subtitle: Text(i.quantity),
                  )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Adicionar Etapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ..._steps.map((s) => ListTile(
                    leading: Text('${s.order}º'),
                    title: Text(s.instruction),
                  )),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save, color: Colors.white,),
                label: Text(isEditing ? 'Salvar Alterações' : 'Salvar Receita'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ratingController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
