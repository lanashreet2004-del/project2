import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reusable app logo placeholder widget.
class AppLogoPlaceholder extends StatelessWidget {
  const AppLogoPlaceholder({super.key, this.size = 96, this.iconSize = 44});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.document_scanner_outlined,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
