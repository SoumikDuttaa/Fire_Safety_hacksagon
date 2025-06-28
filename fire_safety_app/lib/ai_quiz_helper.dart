import 'dart:convert'; // ✅ Needed for jsonDecode
import 'package:google_generative_ai/google_generative_ai.dart';

class AIQuizHelper {
  static Future<List<Map<String, dynamic>>> generateQuiz(String topic, String videoUrl) async {
    final model = GenerativeModel(
      model: 'models/gemini-pro',
      apiKey: 'AIzaSyCN1aNots12wOGP1KMGpw9TuGmiYObGSH4', // 🔑 Replace with your actual Gemini API key
    );

    final prompt = '''
Generate 5 multiple choice questions (with 4 options each) from this topic: "$topic".
Format your response as a JSON list like:
[
  {
    "question": "...",
    "options": ["A", "B", "C", "D"],
    "answer": "..."
  }
]
''';

    try {
      final content = await model.generateContent([Content.text(prompt)]);
      final responseText = content.text;
      print("🧠 Gemini raw output: $responseText");

      if (responseText == null) return [];

      final parsed = jsonDecode(responseText) as List;
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      print("❌ Error generating or parsing quiz: $e");
      return [];
    }
  }
}
