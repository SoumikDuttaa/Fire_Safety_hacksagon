import 'package:flutter/material.dart';

class QuizUnderstandingFire extends StatefulWidget {
  const QuizUnderstandingFire({super.key});

  @override
  State<QuizUnderstandingFire> createState() => _QuizUnderstandingFireState();
}

class _QuizUnderstandingFireState extends State<QuizUnderstandingFire> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the chemical process that causes fire?',
      'options': ['Oxidation', 'Photosynthesis', 'Evaporation', 'Fusion'],
      'answer': 'Oxidation',
    },
    {
      'question': 'Which of the following is NOT a method of heat transfer?',
      'options': ['Conduction', 'Convection', 'Radiation', 'Sublimation'],
      'answer': 'Sublimation',
    },
    {
      'question': 'Which factor influences the spread of fire the most?',
      'options': ['Humidity', 'Wind', 'Rainfall', 'Soil type'],
      'answer': 'Wind',
    },
  ];

  int _currentQuestion = 0;
  int _score = 0;
  bool _showResult = false;

  void _checkAnswer(String selected) {
    final correctAnswer = _questions[_currentQuestion]['answer'];
    if (selected == correctAnswer) {
      _score++;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() => _showResult = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz: Fire Behavior")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showResult
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Quiz Completed!", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text("Your Score: $_score / ${_questions.length}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Tutorials"),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${_currentQuestion + 1}: ${_questions[_currentQuestion]['question']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ...(_questions[_currentQuestion]['options'] as List<String>).map(
                    (option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(option),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
