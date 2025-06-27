// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class AnimatedFireBackground extends StatefulWidget {
  final Widget child;

  const AnimatedFireBackground({super.key, required this.child});

  @override
  _AnimatedFireBackgroundState createState() => _AnimatedFireBackgroundState();
}

class _AnimatedFireBackgroundState extends State<AnimatedFireBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final List<Ripple> _ripples = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = _controller.drive(
      TweenSequence<Color?>([
        TweenSequenceItem(
          tween: ColorTween(
            begin: const Color.fromARGB(255, 255, 255, 255),
            end: const Color.fromARGB(255, 255, 255, 255),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: const Color.fromARGB(255, 255, 255, 255),
            end: const Color.fromARGB(255, 255, 255, 255),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: const Color.fromARGB(255, 255, 255, 255),
            end: const Color.fromARGB(255, 255, 255, 255),
          ),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(
            begin: const Color.fromARGB(255, 255, 255, 255),
            end: const Color.fromARGB(255, 255, 255, 255),
          ),
          weight: 1,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRipple(Offset position) {
    setState(() {
      _ripples.add(Ripple(position: position, startTime: DateTime.now()));
      // Add a second ripple slightly delayed
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _ripples.add(Ripple(position: position, startTime: DateTime.now()));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _addRipple(details.localPosition);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                ),
                ..._ripples.map(
                  (ripple) => RippleEffect(
                    ripple: ripple,
                    colorAnimation: _colorAnimation,
                    onRippleEnd: () {
                      if (mounted) {
                        setState(() {
                          _ripples.remove(ripple);
                        });
                      }
                    },
                  ),
                ),
                widget.child,
              ],
            ),
          );
        },
      ),
    );
  }
}

class Ripple {
  final Offset position;
  final DateTime startTime;

  Ripple({required this.position, required this.startTime});
}

class RippleEffect extends StatefulWidget {
  final Ripple ripple;
  final Animation<Color?> _colorAnimation;
  final VoidCallback onRippleEnd;

  const RippleEffect({
    super.key,
    required this.ripple,
    required Animation<Color?> colorAnimation,
    required this.onRippleEnd,
  }) : _colorAnimation = colorAnimation;

  @override
  _RippleEffectState createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _rippleController.forward();

    _rippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRippleEnd();
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double maxRadius = size.width * 0.7;

    return Positioned(
      left: widget.ripple.position.dx - maxRadius * _rippleAnimation.value,
      top: widget.ripple.position.dy - maxRadius * _rippleAnimation.value,
      child: Opacity(
        opacity: (0.8 - _rippleAnimation.value).clamp(0.0, 1.0),
        child: Container(
          width: maxRadius * 2 * _rippleAnimation.value,
          height: maxRadius * 2 * _rippleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(
                0.8 * (1 - _rippleAnimation.value),
              ),
              width: 8,
            ),
          ),
        ),
      ),
    );
  }
}
