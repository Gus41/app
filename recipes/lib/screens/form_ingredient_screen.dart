import 'package:flutter/material.dart';
import 'package:recipes/models/ingredients.dart';

class FormIngredientScreen extends StatefulWidget {
  const FormIngredientScreen({super.key, this.ingredient});

  final Ingredient? ingredient;

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
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _name = widget.ingredient!.name;
      _quantity = widget.ingredient!.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Adicionar Ingrediente'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: const TextStyle(color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do ingrediente.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: const TextStyle(color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a quantidade.';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _submitForm,
                child: const Text('Salvar Ingrediente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
