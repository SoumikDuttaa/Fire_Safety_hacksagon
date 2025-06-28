import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> generateQuizFromTopic() async {
  const apiKey = 'YOUR_GEMINI_API_KEY'; // 🔐 Replace with your actual key
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
  );

  final prompt = '''
Generate 10 multiple choice questions (MCQs) with 4 options each from the video topic:
"Understanding Fire Behavior" — https://www.youtube.com/watch?v=U9HgTQsH_m4

Format each question as:
Q: [question]
A) [option1]
B) [option2]
C) [option3]
D) [option4]
Answer: [correct option letter]

Make the questions educational and varied in difficulty.
''';

  try {
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No quiz generated.';
  } catch (e) {
    return 'Error generating quiz: $e';
  }
}
