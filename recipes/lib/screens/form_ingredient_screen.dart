import 'package:flutter/material.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:uuid/uuid.dart';

class FormIngredientScreen extends StatefulWidget {
  final Ingredient? ingredient;

  const FormIngredientScreen({Key? key, this.ingredient}) : super(key: key);

  @override
  _FormIngredientScreenState createState() => _FormIngredientScreenState();
}

class _FormIngredientScreenState extends State<FormIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  bool get isEditing => widget.ingredient != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.ingredient!.name;
      _quantityController.text = widget.ingredient!.quantity;
    }
  }

  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      final ingredient = Ingredient(
        id: isEditing ? widget.ingredient!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        quantity: _quantityController.text.trim(),
      );
      Navigator.of(context).pop(ingredient);
    }
  }

  void _deleteIngredient() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Ingrediente' : 'Novo Ingrediente',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteIngredient,
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => (value == null || value.isEmpty) ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (value) => (value == null || value.isEmpty) ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
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
    _quantityController.dispose();
    super.dispose();
  }
}
