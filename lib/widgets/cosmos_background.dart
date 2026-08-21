// Fondo animado del Cosmos.
// Gradiente radial que oscila sutilmente + nebulosa que se desplaza lentamente.

import 'dart:math';
import 'package:flutter/material.dart';
import '../temas/colores_app.dart';

class CosmosBackground extends StatefulWidget {
  const CosmosBackground({super.key});

  @override
  State<CosmosBackground> createState() => _CosmosBackgroundState();
}

class _CosmosBackgroundState extends State<CosmosBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
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
      builder: (context, child) {
        return SizedBox.expand(
          child: CustomPaint(
            painter: _CosmosPainter(_controller.value),
          ),
        );
      },
    );
  }
}

// ════ PAINTER ════

class _CosmosPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  _CosmosPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double seconds = progress * 60;

    _drawBackground(canvas, size, seconds);
    _drawNebula(canvas, size, seconds);
  }

  // ── Capa 1: Gradiente radial con oscilación sutil de color ──

  void _drawBackground(Canvas canvas, Size size, double seconds) {
    final bg = ColoresApp.fondo;

    final int bgR = (bg.r * 255.0).round();
    final int bgG = (bg.g * 255.0).round();
    final int bgB = (bg.b * 255.0).round();

    final shiftR = sin(seconds * 0.5) * 5;
    final shiftG = cos(seconds * 0.3) * 5;
    final shiftB = sin(seconds * 0.4) * 8;

    final centerColor = Color.fromARGB(
      255,
      _clamp(bgR + shiftR.toInt() + 10),
      _clamp(bgG + shiftG.toInt()),
      _clamp(bgB + shiftB.toInt() + 15),
    );

    final midColor = Color.fromARGB(
      255,
      (bgR * 0.8).toInt(),
      (bgG * 0.8).toInt(),
      (bgB * 0.9).toInt(),
    );

    final edgeColor = Color.fromARGB(
      255,
      (bgR * 0.4).toInt(),
      (bgG * 0.4).toInt(),
      (bgB * 0.6).toInt(),
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 1.5,
        colors: [centerColor, midColor, edgeColor],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  // ── Capa 2: Nebulosa que se desplaza lentamente ──

  void _drawNebula(Canvas canvas, Size size, double seconds) {
    final double time = seconds * 0.2;

    final double nebulaX = size.width * 0.5 + sin(time) * 100;
    final double nebulaY = size.height * 0.4 + cos(time * 1.3) * 80;

    final nc = ColoresApp.nebulosa;
    final int ncR = (nc.r * 255.0).round();
    final int ncG = (nc.g * 255.0).round();
    final int ncB = (nc.b * 255.0).round();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (nebulaX / size.width) * 2 - 1,
          (nebulaY / size.height) * 2 - 1,
        ),
        radius: 0.5,
        colors: [
          Color.fromRGBO(ncR, ncG, ncB, 0.04),
          Color.fromRGBO(ncR, ncG, ncB, 0.015),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_CosmosPainter oldDelegate) =>
      oldDelegate.progress != progress;

  static int _clamp(int value) => value.clamp(0, 255);
}