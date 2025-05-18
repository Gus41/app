import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const _apiKey = 'AIzaSyALz2t0NF2Jrr2-EiuuDYB_ZPU7-cowdR0';

  Future<String> getResponse(String prompt) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text != null) {
        return text.toString().trim();
      } else {
        throw Exception("Texto não encontrado na resposta.");
      }
    } else {
      print('Corpo da resposta de erro: ${response.body}');
      throw Exception('Erro ao gerar conteúdo da API: ${response.statusCode}');
    }
  }
}
