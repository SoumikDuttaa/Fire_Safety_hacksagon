import 'dart:math';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'fire_quiz_sample.dart';
import 'quiz_understanding_fire.dart';
import 'ai_quiz_helper.dart'; // <-- Helper file for Gemini integration

class UnderstandingFireBehaviorPage extends StatefulWidget {
  const UnderstandingFireBehaviorPage({super.key});

  @override
  State<UnderstandingFireBehaviorPage> createState() =>
      _UnderstandingFireBehaviorPageState();
}

class _UnderstandingFireBehaviorPageState
    extends State<UnderstandingFireBehaviorPage> {
  late YoutubePlayerController _controller;
  bool _videoEnded = false;
  bool _loadingQuiz = false;
  List<Map<String, dynamic>> _generatedQuestions = [];

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'U9HgTQsH_m4',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
      ),
    );

    _controller.listen((event) async {
      if (event.playerState == PlayerState.ended && !_videoEnded) {
        setState(() => _videoEnded = true);

        setState(() => _loadingQuiz = true);
        try {
          _generatedQuestions = await AIQuizHelper.generateQuiz(
            "Understanding Fire Behavior",
            "https://www.youtube.com/watch?v=U9HgTQsH_m4",
          );
          print("✅ Questions fetched: $_generatedQuestions");
        } catch (e) {
          print("❌ Failed to generate quiz: $e");
        }
        setState(() => _loadingQuiz = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFiveRandomQuestions() {
    final List<Map<String, dynamic>> randomList =
        List<Map<String, dynamic>>.from(sampleFireQuiz)..shuffle();
    return randomList.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: const Text("Understanding Fire Behavior")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                player,
                const SizedBox(height: 16),
                const Text(
                  "🔥 Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This module explains how fire behaves under different conditions, including the chemistry of combustion, heat transfer, and factors that influence fire spread.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_videoEnded && !_loadingQuiz)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final selectedQuestions =
                            _generatedQuestions.isNotEmpty
                                ? _generatedQuestions
                                : _getFiveRandomQuestions();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizUnderstandingFire(
                                aiQuestions: selectedQuestions),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                      child: const Text("Take Quiz"),
                    ),
                  ),
                if (_loadingQuiz)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}
