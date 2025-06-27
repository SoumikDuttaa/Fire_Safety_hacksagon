import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _fireFadeController;
  late AnimationController _fireSizeController;
  late AnimationController _extinguisherPulseController;

  @override
  void initState() {
    super.initState();

    // Filling spray animation
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Fire fade animation
    _fireFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fire size animation
    _fireSizeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Extinguisher pulsing animation
    _extinguisherPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _fillController.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
      _fireFadeController.forward();
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(_createFadeRoute());
    });
  }

  Route _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _fillController.dispose();
    _fireFadeController.dispose();
    _fireSizeController.dispose();
    _extinguisherPulseController.dispose();
    super.dispose();
  }

  Widget _buildSprayWithFill() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Static triangle spray shape (background)
        ClipPath(
          clipper: SprayClipper(),
          child: Container(
            width: 100,
            height: 50,
            color: Colors.transparent,
          ),
        ),
        // Animated fill inside the triangle
        ClipPath(
          clipper: SprayClipper(),
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: _fillController.value,
              alignment: Alignment.centerRight,
              child: Container(
                height: 50,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fireplace, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Blaze',
                    style: TextStyle(color: Color.fromARGB(255, 247, 255, 18)),
                  ),
                  TextSpan(
                    text: 'ON',
                    style: TextStyle(color: Color.fromARGB(255, 89, 39, 255)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 Fire animation
                AnimatedBuilder(
                  animation: _fireSizeController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: Tween<double>(begin: 1, end: 0).animate(_fireFadeController),
                      child: Icon(
                        Icons.local_fire_department,
                        size: 50 + (_fireSizeController.value * 20),
                        color: Color.lerp(Colors.orange, Colors.yellow, _fireSizeController.value),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                // 💨 Spray
                SizedBox(
                  width: 100,
                  height: 50,
                  child: AnimatedBuilder(
                    animation: _fillController,
                    builder: (context, child) => _buildSprayWithFill(),
                  ),
                ),
                const SizedBox(width: 4),
                // 🧯 Extinguisher animation
                AnimatedBuilder(
                  animation: _extinguisherPulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_extinguisherPulseController.value * 0.2),
                      child: const Icon(Icons.fire_extinguisher, size: 50, color: Colors.white),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔺 Spray triangle shape
class SprayClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, size.height / 2); // Tip at extinguisher
    path.lineTo(0, 0);                        // Top left
    path.lineTo(0, size.height);              // Bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
