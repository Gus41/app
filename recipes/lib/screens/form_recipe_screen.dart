import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/providers/recipe_provider.dart';
import 'package:recipes/screens/form_ingredient_screen.dart';
import 'package:recipes/screens/form_step_screen.dart';
import 'package:recipes/services/api_service.dart';

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

  void fillField() async {
    final apiService = ApiService();

    try {
      final title = await apiService.getTitle();
      final avaliation = await apiService.getAvaliation();
      final time = await apiService.getTimePreparation();

      setState(() {
        _nameController.text = title;
        _ratingController.text = avaliation;
        _timeController.text = time;
      });
    } catch (e) {
      print('Erro ao preencher os campos: $e');
    }
  }

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
      return;
    }
    fillField();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alterações salvas com sucesso!')),
        );
      } else {
        notifier.addItem(newRecipe);
        Navigator.of(context).pop();
      }
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
      if (_steps.any((step) => step.order == result.order)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe um passo com esse índex')),
        );
        return;
      }

      setState(() {
        _steps.add(result);
        _steps.sort((a, b) => a.order.compareTo(b.order));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF1744),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEditing ? widget.recipe!.name : "Nova Receita",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF1744), 
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _nameController,
                label: 'Título',
                onSaved: (value) => _name = value!.trim(),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Nome inválido.' : null,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _ratingController,
                label: 'Avaliação (0-5)',
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _rating = double.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  final rating = double.tryParse(value ?? '');
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Avaliação inválida.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _timeController,
                label: 'Tempo de Preparo (min)',
                keyboardType: TextInputType.number,
                onSaved: (value) => _preparationTime =
                    Duration(minutes: int.tryParse(value ?? '0') ?? 0),
                validator: (value) {
                  final minutes = int.tryParse(value ?? '');
                  if (minutes == null || minutes < 0) {
                    return 'Tempo inválido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),

              _buildSectionButton('Adicionar Ingrediente', _addIngredient),
              const SizedBox(height: 8),
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListTile(
                    title: Text(ingredient.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(ingredient.quantity,
                        style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.edit, color: Colors.redAccent),
                    onTap: () async {
                      final result =
                          await Navigator.of(context).push<Ingredient>(
                        MaterialPageRoute(
                          builder: (_) =>
                              FormIngredientScreen(ingredient: ingredient),
                        ),
                      );

                      setState(() {
                        if (result == null) {
                          _ingredients.removeAt(index);
                        } else {
                          _ingredients[index] = result;
                        }
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 20),
              const Divider(color: Colors.white24),

              _buildSectionButton('Adicionar Etapa', _addStep),
              const SizedBox(height: 8),
              ..._steps.map((step) {
                return Card(
                  color: const Color(0xFF1E1E1E),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      child: Text('${step.order}'),
                    ),
                    title: Text(step.instruction,
                        style: const TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.edit, color: Colors.redAccent),
                    onTap: () async {
                      final result =
                          await Navigator.of(context).push<StepPreparation>(
                        MaterialPageRoute(
                          builder: (_) => FormStepScreen(step: step),
                        ),
                      );

                      setState(() {
                        if (result == null) {
                          _steps.remove(step);
                        } else {
                          final index = _steps.indexOf(step);
                          _steps[index] = result;
                          _steps.sort((a, b) => a.order.compareTo(b.order));
                        }
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save, color: Colors.white,),
                label: const Text('Salvar Receita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildSectionButton(String text, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, color: Colors.white,),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
