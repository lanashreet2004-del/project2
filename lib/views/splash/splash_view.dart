import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/splash_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Splash matching the SATR · OCR green/gold intro design.
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  static const _bgTop = AppColors.actionGreenDark;
  static const _bgMid = AppColors.actionGreen;
  static const _bgBottom = AppColors.actionGreenLight;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_bgTop, _bgMid, _bgBottom],
                  stops: [0.0, 0.48, 1.0],
                ),
              ),
            ),
            const CustomPaint(painter: _SplashWavePainter()),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  const _SplashLogoCard(),
                  const SizedBox(height: 28),
                  Text(
                    'app.name'.tr,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'app.tagline'.tr,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 5.5,
                        ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogoCard extends StatelessWidget {
  const _SplashLogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        AppConstants.appIconAsset,
        width: 148,
        height: 148,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final topPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final top = Path()
      ..moveTo(w * 0.08, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.22)
      ..cubicTo(w * 0.78, h * 0.08, w * 0.52, h * 0.18, w * 0.22, h * 0.06)
      ..cubicTo(w * 0.12, h * 0.02, w * 0.08, 0, w * 0.08, 0)
      ..close();
    canvas.drawPath(top, topPaint);

    final bottomPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;
    final bottom = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.78)
      ..cubicTo(w * 0.22, h * 0.92, w * 0.48, h * 0.74, w * 0.82, h * 0.90)
      ..cubicTo(w * 0.94, h * 0.96, w, h, w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottom, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
