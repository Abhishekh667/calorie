import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class FoodAnalysisResult {
  final String name;
  final double estimatedCalories;
  final double estimatedProteinG;
  final double estimatedCarbsG;
  final double estimatedFatG;

  FoodAnalysisResult({
    required this.name,
    required this.estimatedCalories,
    required this.estimatedProteinG,
    required this.estimatedCarbsG,
    required this.estimatedFatG,
  });
}

class AIService {
  static const String _apiKey =
      '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'google/gemma-4-31b-it:free';

  final Dio _dio;

  AIService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://calorieflow.app',
            'X-Title': 'Calorie Flow',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  static const String _prompt = '''
You are a nutrition expert. Analyze this food photo and return ONLY valid JSON.
Do NOT include markdown, code blocks, or any text outside the JSON object.

{
  "name": "Name of the dish/meal",
  "estimated_calories": number (total kcal),
  "estimated_protein_g": number (grams),
  "estimated_carbs_g": number (grams),
  "estimated_fat_g": number (grams)
}

If you cannot identify the food, use "Unknown Meal" and estimate based on appearance.
''';

  Future<FoodAnalysisResult?> analyzePhoto(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': _prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'max_tokens': 256,
      });

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      final message = choices[0]['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String?;
      if (text == null) return null;

      final cleaned = _cleanJson(text);
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      return FoodAnalysisResult(
        name: json['name'] as String? ?? 'Unknown Meal',
        estimatedCalories:
            (json['estimated_calories'] as num?)?.toDouble() ?? 0,
        estimatedProteinG:
            (json['estimated_protein_g'] as num?)?.toDouble() ?? 0,
        estimatedCarbsG:
            (json['estimated_carbs_g'] as num?)?.toDouble() ?? 0,
        estimatedFatG: (json['estimated_fat_g'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  String _cleanJson(String text) {
    var clean = text.trim();
    if (clean.startsWith('```')) {
      final firstNewline = clean.indexOf('\n');
      if (firstNewline != -1) {
        clean = clean.substring(firstNewline + 1);
      }
      final lastBackticks = clean.lastIndexOf('```');
      if (lastBackticks != -1) {
        clean = clean.substring(0, lastBackticks);
      }
    }
    return clean.trim();
  }
}
