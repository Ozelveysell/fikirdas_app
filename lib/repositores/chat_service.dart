import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String _apiKey = 'Senin_API_Anahtarin'; // Geçerli API anahtarınızı buraya yerleştirin

  Future<String> getChatResponse(String prompt) async {
    const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

    final response = await http.post(
      Uri.parse('$apiUrl?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print(data); // API'den gelen yanıtı yazdırın

  // Cevabı al
  if (data['candidates'] != null && data['candidates'].isNotEmpty) {
    return data['candidates'][0]['content']['parts'][0]['text'];
  } else {
    throw Exception('Yanıt beklenen yapıda değil.');
  }
} else {
  print('Error: ${response.body}');
  throw Exception('Failed to load response: ${response.statusCode}');
}

  }
}
