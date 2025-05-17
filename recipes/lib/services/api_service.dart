import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const _baseUrl = 'https://randommer.io/api/Text/LoremIpsum';
  static const _apiKey = 'c2eb014150a848abb1380db4501dd736';

  static Future<String> fetchLoremIpsum({int paragraphs = 3}) async {
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
}
