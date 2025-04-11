import 'package:flutter/material.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/screens/form_ingredient_screen.dart';
import 'package:recipes/screens/form_step_screen.dart';

class FormRecipeScreen extends StatefulWidget {
  const FormRecipeScreen({super.key});

  @override
  State<FormRecipeScreen> createState() => _FormRecipeScreenState();
}

class _FormRecipeScreenState extends State<FormRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ingredients = <Ingredient>[];
  final _steps = <StepPreparation>[];

  String _name = '';
  double _rating = 0.0;
  Duration _preparationTime = Duration.zero;

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Receita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome da Receita'),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Informe um nome.' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Avaliação (0-5)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _rating = double.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  final rating = double.tryParse(value ?? '');
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Avaliação deve estar entre 0 e 5.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tempo de Preparo (min)'),
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
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Ingrediente'),
              ),
              ..._ingredients.map((i) => ListTile(
                title: Text(i.name),
                subtitle: Text(i.quantity),
              )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Etapa'),
              ),
              ..._steps.map((s) => ListTile(
                leading: Text('${s.order}º'),
                title: Text(s.instruction),
              )),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Receita'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
