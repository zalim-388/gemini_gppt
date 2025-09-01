import 'dart:convert';

import 'package:gemini_gpt/main.dart';
import 'package:gemini_gpt/repositary/model/geminimodel.dart';
import 'package:http/http.dart' as http;

class GeminiApi {
  final String apiKey = apikeyy;

  Future<Model> getGemini(String prompt) async {
    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
    
      final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]
              ?['text'] ??
          'No response';
      return Model(url: text); 
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}
