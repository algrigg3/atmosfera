import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 15))
          ..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Color.lerp(const Color(0xFF00B7E1), const Color(0xFFdbeafe),
                    _animation.value)!,
                Color.lerp(const Color(0xFFdbeafe), const Color(0xFF1e3a8a),
                    _animation.value)!,
                Color.lerp(const Color(0xFF1e3a8a), const Color(0xFF00B7E1),
                    _animation.value)!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class FloatingPin extends StatefulWidget {
  final Color color;

  const FloatingPin({
    super.key,
    this.color = Colors.white, // default to white
  });

  @override
  State<FloatingPin> createState() => _FloatingPinState();
}

class _FloatingPinState extends State<FloatingPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double left;
  late double top;
  final Random _random = Random();

  void randomizePosition() {
    setState(() {
      left = _random.nextDouble() * MediaQuery.of(context).size.width;
      top = _random.nextDouble() * MediaQuery.of(context).size.height;
    });
  }

  @override
  void initState() {
    super.initState();
    left = _random.nextDouble() * 500;
    top = _random.nextDouble() * 800;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5 + _random.nextInt(5)),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          randomizePosition();
          _controller.forward(from: 0);
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: left,
          top: top + _controller.value * 30, // drop down 30px
          child: Icon(
            Icons.location_pin,
            color: widget.color.withOpacity(0.2), // use passed color
            size: 24,
          ),
        );
      },
    );
  }
}
