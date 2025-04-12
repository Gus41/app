import 'package:flutter/material.dart';
import 'package:recipes/models/step_preparation.dart';

class FormStepScreen extends StatefulWidget {
  const FormStepScreen({super.key});

  @override
  State<FormStepScreen> createState() => _FormStepScreenState();
}

class _FormStepScreenState extends State<FormStepScreen> {
  final _formKey = GlobalKey<FormState>();
  int _order = 1;
  String _instruction = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newStep = StepPreparation(
        order: _order,
        instruction: _instruction,
      );

      Navigator.of(context).pop(newStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Etapa'),
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
                decoration: const InputDecoration(labelText: 'Ordem'),
                keyboardType: TextInputType.number,
                initialValue: '1',
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Informe um número válido.';
                  }
                  return null;
                },
                onSaved: (value) => _order = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Instrução'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a instrução de preparo.';
                  }
                  return null;
                },
                onSaved: (value) => _instruction = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
