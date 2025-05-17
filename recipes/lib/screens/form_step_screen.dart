import 'package:flutter/material.dart';
import 'package:recipes/models/step_preparation.dart';
import 'package:recipes/services/api_service.dart';

class FormStepScreen extends StatefulWidget {
  final StepPreparation? step;

  const FormStepScreen({super.key, this.step});

  @override
  State<FormStepScreen> createState() => _FormStepScreenState();
}

class _FormStepScreenState extends State<FormStepScreen> {
  final _formKey = GlobalKey<FormState>();
  int _order = 1;
  final TextEditingController _instructionController = TextEditingController();

  void fillFields() async {
    ApiService _apiService = ApiService();
    try {
      String instruction = await _apiService.getInstruction();
      setState(() {
        _instructionController.text = instruction;
      });
    } catch (e) {
      print('Erro ao buscar instrução: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.step != null) {
      _order = widget.step!.order;
      _instructionController.text = widget.step!.instruction;
    } else {
      fillFields();
    }
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newStep = StepPreparation(
        order: _order,
        instruction: _instructionController.text,
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
        actions: [
          if (widget.step != null)
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }),
        ],
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
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 1) {
                    return 'Informe um número válido.';
                  }
                  return null;
                },
                onSaved: (value) => _order = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionController,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a instrução de preparo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize:
                      Size(double.infinity, 50), // Botão com altura maior
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
