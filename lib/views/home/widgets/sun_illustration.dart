import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_context.dart';

/// Sun illustration for the welcome card — uses theme gold accent.
class SunIllustration extends StatelessWidget {
  const SunIllustration({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final gold = context.appColors.accent;
    final goldSoft = context.colors.tertiaryContainer;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(8, (index) {
            return Transform.rotate(
              angle: index * 3.14159 / 4,
              child: Container(
                width: 6,
                height: size * 0.35,
                margin: EdgeInsets.only(bottom: size * 0.55),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold,
              border: Border.all(color: goldSoft, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}
