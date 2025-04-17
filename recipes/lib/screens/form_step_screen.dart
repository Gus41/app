import 'package:flutter/material.dart';
import 'package:recipes/models/step_preparation.dart';

class FormStepScreen extends StatefulWidget {
  final StepPreparation? step;

  const FormStepScreen({super.key, this.step});

  @override
  State<FormStepScreen> createState() => _FormStepScreenState();
}

class _FormStepScreenState extends State<FormStepScreen> {
  final _formKey = GlobalKey<FormState>();
  int _order = 1;
  String _instruction = '';

  @override
  void initState() {
    super.initState();
    if (widget.step != null) {
      _order = widget.step!.order;
      _instruction = widget.step!.instruction;
    }
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.step == null ? 'Adicionar Etapa' : 'Editar Etapa'),
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
                decoration: InputDecoration(
                  labelText: 'Ordem',
                  labelStyle: const TextStyle(color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                initialValue: _order.toString(),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Informe um número válido.';
                  }
                  return null;
                },
                onSaved: (value) => _order = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Instrução',
                  labelStyle: const TextStyle(color: Colors.red),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                initialValue: _instruction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a instrução de preparo.';
                  }
                  return null;
                },
                onSaved: (value) => _instruction = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50), // Botão com altura maior
                ),
                onPressed: _submitForm,
                child: const Text('Salvar Etapa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
