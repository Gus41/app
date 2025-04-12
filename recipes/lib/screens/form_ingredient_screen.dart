import 'package:flutter/material.dart';
import 'package:recipes/models/ingredients.dart';

class FormIngredientScreen extends StatefulWidget {
  const FormIngredientScreen({super.key});

  @override
  State<FormIngredientScreen> createState() => _FormIngredientScreenState();
}

class _FormIngredientScreenState extends State<FormIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _quantity = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newIngredient = Ingredient(
        name: _name,
        quantity: _quantity,
      );
      Navigator.of(context).pop(newIngredient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Ingrediente'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do ingrediente.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a quantidade.';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
