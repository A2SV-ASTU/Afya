import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

abstract class GeminiRemoteDataSource {
  Future<String> generateHealthResponse(String userPrompt, List<Map<String, String>> previousHistory);
}

@LazySingleton(as: GeminiRemoteDataSource)
class GeminiRemoteDataSourceImpl implements GeminiRemoteDataSource {
  final Dio _dio;

  static const String _systemInstruction = 
      "You are Afya AI, a compassionate and knowledgeable health assistant in the Afya digital healthcare ecosystem. "
      "Your objective is to provide helpful, general health education, wellness guidance, lifestyle advice, and context on medical concepts. "
      "CRITICAL SAFETY RULE: You MUST NEVER provide formal medical diagnoses, prescribe medications, or claim to replace a real doctor's clinical evaluation. "
      "Always maintain a supportive, warm, and structured tone. Use bullet points or short paragraphs for readability. "
      "If the user asks about dangerous emergency symptoms (such as chest pain, severe shortness of breath, sudden numbness, or unmanageable pain), "
      "promptly advise them to seek immediate emergency medical care.";

  GeminiRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<String> generateHealthResponse(
    String userPrompt,
    List<Map<String, String>> previousHistory,
  ) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['GEMINI_KEY'] ?? '';

    if (apiKey.trim().isNotEmpty) {
      final modelsToTry = [
        'gemini-3.6-flash',
        'gemini-3.5-flash',
        'gemini-3.0-flash',
        'gemini-2.5-flash',
        'gemini-1.5-flash',
        'gemini-pro',
      ];

      final contents = <Map<String, dynamic>>[];

      // Previous conversation history
      for (final item in previousHistory) {
        final role = item['role'] == 'user' ? 'user' : 'model';
        final text = item['text'] ?? '';
        if (text.isNotEmpty) {
          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ]
          });
        }
      }

      // Current user prompt
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userPrompt}
        ]
      });

      final payload = {
        'system_instruction': {
          'parts': [
            {'text': _systemInstruction}
          ]
        },
        'contents': contents,
      };

      for (final modelName in modelsToTry) {
        try {
          final url =
              'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=${apiKey.trim()}';

          final response = await _dio.post(
            url,
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) => status != null && status < 500,
            ),
            data: payload,
          );

          if (response.statusCode == 200 && response.data != null) {
            final data = response.data is String
                ? jsonDecode(response.data)
                : response.data;

            final candidates = data['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final content = candidates[0]['content'];
              final parts = content['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                final text = parts[0]['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  return text;
                }
              }
            }
          }
        } catch (_) {
          // Try next model if 404 or unsupported
        }
      }
    }

    // Intelligent general health fallback response when GEMINI_API_KEY is not yet added
    return _generateFallbackHealthResponse(userPrompt);
  }

  String _generateFallbackHealthResponse(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('headache') || lower.contains('head pain')) {
      return "Headaches can stem from various everyday factors such as stress, dehydration, lack of sleep, eye strain, or muscle tension.\n\n"
          "**General Self-Care Tips:**\n"
          "• Stay well hydrated by drinking plenty of water.\n"
          "• Rest in a quiet, dark room.\n"
          "• Practice gentle neck stretches and relaxation techniques.\n\n"
          "*Note: If your headache is sudden, severe ('thunderclap'), accompanied by fever, stiff neck, or vision changes, please consult a healthcare professional immediately.*";
    }

    if (lower.contains('sleep') || lower.contains('insomnia') || lower.contains('tired')) {
      return "Good sleep hygiene is essential for mental clarity and physical recovery.\n\n"
          "**Tips for Better Sleep:**\n"
          "• Keep a consistent sleep schedule, even on weekends.\n"
          "• Avoid screen time (phones, tablets) 1 hour before bed.\n"
          "• Keep your bedroom cool, quiet, and dark.\n"
          "• Limit caffeine and heavy meals in the evening.";
    }

    if (lower.contains('fever') || lower.contains('temperature') || lower.contains('cold') || lower.contains('flu')) {
      return "A fever is usually a sign that your immune system is actively fighting an infection.\n\n"
          "**General Advice:**\n"
          "• Get ample rest and avoid strenuous activity.\n"
          "• Drink fluids frequently (water, warm tea, clear broths) to avoid dehydration.\n"
          "• Monitor your body temperature regularly.\n\n"
          "*Important: Please seek medical evaluation if a fever persists over 3 days or exceeds 39°C (102°F).*";
    }

    if (lower.contains('blood pressure') || lower.contains('vitals') || lower.contains('heart rate')) {
      return "Tracking your vital signs helps you stay informed about your cardiovascular wellness.\n\n"
          "**General Guidance:**\n"
          "• Rest quietly for 5 minutes before taking blood pressure measurements.\n"
          "• Maintain a balanced low-sodium diet rich in vegetables and fruit.\n"
          "• Engage in regular moderate physical activity like walking.\n\n"
          "*Always discuss your specific vitals trends with your clinic or doctor.*";
    }

    return "Thank you for reaching out to **Afya AI**.\n\n"
        "I am designed to help answer general health questions, share wellness insights, and assist with health education.\n\n"
        "• **Hydration & Nutrition:** Drink 2-3 liters of water daily and aim for balanced meals.\n"
        "• **Physical Activity:** 30 minutes of moderate daily exercise supports heart & brain health.\n"
        "• **Preventive Care:** Regular health check-ups and tracking vitals are key to long-term wellness.\n\n"
        "*Disclaimer: AI provides general information and does not replace professional medical advice or clinical diagnosis.*";
  }
}
