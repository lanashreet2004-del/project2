import 'package:flutter/material.dart';

import '../theme/app_theme_context.dart';

/// Reusable app logo placeholder widget.
class AppLogoPlaceholder extends StatelessWidget {
  const AppLogoPlaceholder({super.key, this.size = 96, this.iconSize = 44});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, context.colors.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.document_scanner_outlined,
        size: iconSize,
        color: context.colors.onPrimary,
      ),
    );
  }
}
