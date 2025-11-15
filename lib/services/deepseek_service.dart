import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message_model.dart';
import '../config/api_config.dart';

class DeepSeekService {
  final String apiKey;
  
  DeepSeekService({required this.apiKey});

  Future<String> sendMessage(List<Message> messages) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': ApiConfig.model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'temperature': ApiConfig.temperature,
          'max_tokens': ApiConfig.maxTokens,
          'top_p': ApiConfig.topP,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('خطا در ارتباط با API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در ارسال پیام: $e');
    }
  }

  // Stream برای پاسخ‌های real-time
  Stream<String> streamMessage(List<Message> messages) async* {
    final request = http.Request('POST', Uri.parse(ApiConfig.apiUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });
    
    request.body = jsonEncode({
      'model': ApiConfig.model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': ApiConfig.temperature,
      'max_tokens': ApiConfig.maxTokens,
      'stream': true,
    });

    final response = await request.send();
    
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data);
            final content = json['choices'][0]['delta']['content'];
            if (content != null) {
              yield content;
            }
          } catch (e) {
            // Skip parsing errors
          }
        }
      }
    }
  }
}