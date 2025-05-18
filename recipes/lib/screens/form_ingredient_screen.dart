import 'package:flutter/material.dart';
import 'package:recipes/models/ingredients.dart';
import 'package:recipes/services/api_service.dart';
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

  void fillFields() async {
    ApiService _apiService = ApiService();
    try {
      Ingredient ingredient = await _apiService.getIgredient();
      setState(() {
        _nameController.text = ingredient.name;
        _quantityController.text = ingredient.quantity;
      });
    } catch (e) {
      print('Erro ao preencher campos de ingrediente: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.ingredient!.name;
      _quantityController.text = widget.ingredient!.quantity;
      return;
    }
    fillFields();
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
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Ingrediente' : 'Novo Ingrediente',
          style: const TextStyle(
            color: Color(0xFFFF1744), 
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF1744),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFF1744)),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF1744)),
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: const TextStyle(color: Color(0xFFFF1744)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF1744)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  labelStyle: const TextStyle(color: Color(0xFFFF1744)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF1744)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1744),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
