import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class HuggingFaceApiException implements Exception {
  final String message;
  final int? statusCode;
  HuggingFaceApiException(this.message, {this.statusCode});
  @override
  String toString() => 'HuggingFaceApiException($statusCode): $message';
}

class HuggingFaceApiClient {
  final String token;
  final http.Client _client;

  HuggingFaceApiClient({required this.token, http.Client? client})
      : _client = client ?? http.Client();

  Uri _uriForModel(String model) =>
      Uri.parse('https://api-inference.huggingface.co/models/$model');

  Future<String> generateText({
    required String model,
    required String prompt,
  }) async {
    final url = _uriForModel(model);

    final res = await _client
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': prompt,
            // Conservative generation params; adjust later.
            'parameters': {
              'max_new_tokens': 220,
              'temperature': 0.7,
              'return_full_text': false,
            },
            'options': {
              'wait_for_model': true,
            }
          }),
        )
        .timeout(AppConst.apiTimeout);

    if (res.statusCode == 401) {
      throw HuggingFaceApiException(
        'Unauthorized (401). Check your HF_TOKEN.',
        statusCode: 401,
      );
    }

    // Hugging Face often returns 503 when model is loading/cold-start.
    if (res.statusCode == 503) {
      throw HuggingFaceApiException(
        'Model is loading (503). Try again in ~10–30 seconds.',
        statusCode: 503,
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HuggingFaceApiException(
        'API error (${res.statusCode}): ${res.body}',
        statusCode: res.statusCode,
      );
    }

    final dynamic decoded = jsonDecode(res.body);

    // Common formats:
    // 1) List: [{ "generated_text": "..." }]
    // 2) Map: { "generated_text": "..." } OR error object
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first;
      if (first is Map && first['generated_text'] is String) {
        return (first['generated_text'] as String).trim();
      }
    }

    if (decoded is Map) {
      if (decoded['generated_text'] is String) {
        return (decoded['generated_text'] as String).trim();
      }
      if (decoded['error'] is String) {
        throw HuggingFaceApiException(decoded['error'] as String);
      }
    }

    // Fallback: return raw string
    return res.body.toString().trim();
  }
}
