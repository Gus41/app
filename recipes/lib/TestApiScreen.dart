import 'package:flutter/material.dart';
import '/services/api_service.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final ApiService apiService = ApiService();
  String apiResult = 'Carregando...';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final result = await ApiService.fetchLoremIpsum();
      setState(() {
        apiResult = result;
      });
    } catch (e) {
      setState(() {
        apiResult = 'Erro ao buscar dados: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste API Lorem Ipsum'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(apiResult),
      ),
    );
  }
}
