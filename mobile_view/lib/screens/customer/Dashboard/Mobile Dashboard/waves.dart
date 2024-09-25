import 'dart:math';

import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double animationValue; // Animation value to control the wave height

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paintGreen = Paint()
      ..color = Colors.blue.shade400 // Green color for the wave
      ..style = PaintingStyle.fill; // Filling the wave

    final pathGreen = Path();
    pathGreen.moveTo(0, size.height);
    pathGreen.lineTo(0, size.height * 0.6); // Starting point for the wave
    for (var i = 0; i < size.width; i++) {
      final x = i.toDouble();
      final y = size.height * 0.56 +
          animationValue *
              5 *
              sin((i / size.width) * 3 * pi); // Calculate wave shape
      pathGreen.lineTo(x, y); // Define wave path
    }
    pathGreen.lineTo(size.width, size.height); // Complete the wave path
    pathGreen.close();

    canvas.drawPath(pathGreen, paintGreen); // Draw the green wave
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint the wave continuously
  }
}

class WaveAnimation extends StatefulWidget {
  @override
  _WaveAnimationState createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // Synchronize animation with this widget
      duration: Duration(seconds: 1), // Animation duration
    )..repeat(reverse: true); // Repeat the animation back and forth
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
              140,
              140), // Set the size of the custom paint
          painter: WavePainter(
              _controller.value), // Use the WavePainter to paint the wave
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }
}