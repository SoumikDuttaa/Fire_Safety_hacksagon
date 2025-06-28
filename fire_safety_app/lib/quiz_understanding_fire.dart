import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class QuizUnderstandingFire extends StatefulWidget {
  final List<Map<String, dynamic>> aiQuestions;

  const QuizUnderstandingFire({super.key, required this.aiQuestions});

  @override
  State<QuizUnderstandingFire> createState() => _QuizUnderstandingFireState();
}

class _QuizUnderstandingFireState extends State<QuizUnderstandingFire> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _showResult = false;

  late final List<Map<String, dynamic>> _selectedQuestions;
  List<String> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _selectedQuestions = widget.aiQuestions.length > 10
        ? widget.aiQuestions.sublist(0, 10)
        : widget.aiQuestions;
  }

  void _checkAnswer(String selected) {
    final correctAnswer = _selectedQuestions[_currentQuestion]['answer'];
    if (_userAnswers.length <= _currentQuestion) {
      _userAnswers.add(selected);
    }

    if (selected.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      _score++;
    }

    if (_currentQuestion < _selectedQuestions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      setState(() => _showResult = true);
    }
  }

  Future<void> _generateReportFile() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('🔥 Fire Behavior Quiz Report', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 16),
          pw.Text('Score: $_score / ${_selectedQuestions.length}', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 12),
          ...List.generate(_selectedQuestions.length, (i) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Q${i + 1}: ${_selectedQuestions[i]['question']}"),
                pw.Text("Your Answer: ${_userAnswers[i]}"),
                pw.Text("Correct Answer: ${_selectedQuestions[i]['answer']}", style: pw.TextStyle(color: PdfColors.green)),
                pw.SizedBox(height: 10),
              ],
            );
          }),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/fire_quiz_report.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz: Fire Behavior")),
        body: const Center(
          child: Text("No questions available. Please try again."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade100,
        title: const Text("Quiz 📝 - Introduction to Fire Safety & Classes of Fire"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.black54),
                SizedBox(width: 4),
                Text("10:00", style: TextStyle(color: Colors.black)),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showResult
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Quiz Completed!", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    "Your Score: $_score / ${_selectedQuestions.length}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateReportFile,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text("Download Report"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Tutorials"),
                  )
                ],
              )
            : Column(
                children: [
                  // Stepper Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_selectedQuestions.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: index == _currentQuestion ? Colors.deepPurpleAccent : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${index + 1}".padLeft(2, '0'),
                          style: TextStyle(
                            color: index == _currentQuestion ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Question Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Question ${_currentQuestion + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(
                            _selectedQuestions[_currentQuestion]['question'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ...List.generate(
                              (_selectedQuestions[_currentQuestion]['options'] as List<String>).length, (i) {
                            final option = _selectedQuestions[_currentQuestion]['options'][i];
                            final label = String.fromCharCode(65 + i); // A, B, C, D
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: OutlinedButton(
                                onPressed: () => _checkAnswer(option),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  side: const BorderSide(color: Colors.deepPurple),
                                  backgroundColor: _userAnswers.length > _currentQuestion &&
                                          _userAnswers[_currentQuestion] == option
                                      ? Colors.deepPurple.shade100
                                      : Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: Colors.deepPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(label, style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(option, style: const TextStyle(fontSize: 16))),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentQuestion > 0
                            ? () => setState(() => _currentQuestion--)
                            : null,
                        child: const Text("← Previous"),
                      ),
                      TextButton(
                        onPressed: _currentQuestion < _selectedQuestions.length - 1
                            ? () => setState(() => _currentQuestion++)
                            : null,
                        child: const Text("Next →"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
