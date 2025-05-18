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
      backgroundColor: const Color(0xFF121212), // fundo preto fosco
      appBar: AppBar(
        title: Text(
          widget.step == null ? 'Adicionar Etapa' : 'Editar Etapa',
          style: const TextStyle(
            color: Color(0xFFFF1744), // vermelho vibrante
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFFF1744),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (widget.step != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF1744)),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
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
                initialValue: _order.toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Ordem',
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
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Instrução',
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a instrução de preparo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1744),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text('Salvar Etapa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
