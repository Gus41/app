import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:recipes/models/ingredients.dart';

class ApiService {
  static const _baseUrl = 'https://randommer.io/api/Text/LoremIpsum';
  static const _apiKey = 'c2eb014150a848abb1380db4501dd736';

  static Future<String> fetchLoremIpsum({int paragraphs = 1}) async {
    final url = Uri.parse('$_baseUrl?loremType=normal&type=paragraphs&number=$paragraphs');

    final response = await http.get(
      url,
      headers: {'X-Api-Key': _apiKey},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Erro ao buscar texto da API: ${response.statusCode}');
    }
  }

  Future<String> getTitle() async {
    final text = await fetchLoremIpsum(paragraphs: 1);
    return text.split(' ').take(3).join(' ').replaceAll('.', '');
  }

  Future<String> getAvaliation() async {
    final random = Random();
    return (random.nextDouble() * 5).toStringAsFixed(1); 
  }

  Future<String> getTimePreparation() async {
    final random = Random();
    return (1 + random.nextInt(99)).toString(); 
  }

  Future<Ingredient> getIgredient() async {
    final text = await fetchLoremIpsum(paragraphs: 1);
    final words = text.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();
    final random = Random();

    final name = words[random.nextInt(words.length)].replaceAll(RegExp(r'[^\w]'), '');
    final quantity = "${1 + random.nextInt(10)}";

    return Ingredient(name: name, quantity: quantity);
  }

  Future<String> getInstruction() async {
    final text = await fetchLoremIpsum(paragraphs: 1);
    return text.split('.').first + '.';
  }
}
