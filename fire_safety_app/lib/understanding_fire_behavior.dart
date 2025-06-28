import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'quiz_understanding_fire.dart';

class UnderstandingFireBehaviorPage extends StatefulWidget {
  const UnderstandingFireBehaviorPage({super.key});

  @override
  State<UnderstandingFireBehaviorPage> createState() => _UnderstandingFireBehaviorPageState();
}

class _UnderstandingFireBehaviorPageState extends State<UnderstandingFireBehaviorPage> {
  late YoutubePlayerController _controller;
  bool _videoEnded = false;

  @override
  void initState() {
    super.initState();

    const videoUrl = 'https://www.youtube.com/watch?v=BLb8HnAo9GE'; // Replace with your actual video
    final videoId = YoutubePlayer.convertUrlToId(videoUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_onVideoChange);
  }

  void _onVideoChange() {
    if (_controller.value.playerState == PlayerState.ended && !_videoEnded) {
      setState(() => _videoEnded = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
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
                if (_videoEnded)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const QuizUnderstandingFire(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                      child: const Text("Take Quiz"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
