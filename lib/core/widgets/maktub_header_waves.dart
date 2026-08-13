import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bottom clip for Maktub headers — smooth wave into page content.
class MaktubHeaderWaveClipper extends CustomClipper<Path> {
  const MaktubHeaderWaveClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.78)
      ..cubicTo(
        w * 0.88,
        h * 0.86,
        w * 0.72,
        h * 0.98,
        w * 0.55,
        h * 0.92,
      )
      ..cubicTo(
        w * 0.38,
        h * 0.86,
        w * 0.22,
        h * 0.72,
        0,
        h * 0.82,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant MaktubHeaderWaveClipper oldClipper) => false;
}

/// Layered green waves + vertical gradient for header depth.
class MaktubHeaderBackgroundPainter extends CustomPainter {
  MaktubHeaderBackgroundPainter({
    required this.darkGreen,
    required this.midGreen,
    required this.lightGreen,
  });

  final Color darkGreen;
  final Color midGreen;
  final Color lightGreen;

  factory MaktubHeaderBackgroundPainter.fromTheme({required bool isDark}) {
    if (isDark) {
      return MaktubHeaderBackgroundPainter(
        darkGreen: const Color(0xFF0A2E1A),
        midGreen: AppColors.actionGreenDark,
        lightGreen: AppColors.actionGreen,
      );
    }
    return MaktubHeaderBackgroundPainter(
      darkGreen: AppColors.actionGreenDark,
      midGreen: AppColors.actionGreen,
      lightGreen: AppColors.actionGreenLight,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [darkGreen, midGreen, lightGreen],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, gradient);

    final wavePaint1 = Paint()
      ..color = lightGreen.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final wave1 = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.25, h * 0.22, w * 0.45, h * 0.48, w * 0.7, h * 0.32)
      ..cubicTo(w * 0.88, h * 0.22, w, h * 0.38, w, h * 0.42)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave1, wavePaint1);

    final wavePaint2 = Paint()
      ..color = darkGreen.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final wave2 = Path()
      ..moveTo(0, h * 0.55)
      ..cubicTo(w * 0.2, h * 0.68, w * 0.4, h * 0.48, w * 0.62, h * 0.62)
      ..cubicTo(w * 0.82, h * 0.74, w * 0.95, h * 0.58, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave2, wavePaint2);

    final wavePaint3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final wave3 = Path()
      ..moveTo(0, h * 0.2)
      ..cubicTo(w * 0.3, h * 0.08, w * 0.55, h * 0.28, w * 0.85, h * 0.12)
      ..lineTo(w, h * 0.18)
      ..lineTo(w, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(wave3, wavePaint3);
  }

  @override
  bool shouldRepaint(covariant MaktubHeaderBackgroundPainter oldDelegate) {
    return oldDelegate.darkGreen != darkGreen ||
        oldDelegate.midGreen != midGreen ||
        oldDelegate.lightGreen != lightGreen;
  }
}
