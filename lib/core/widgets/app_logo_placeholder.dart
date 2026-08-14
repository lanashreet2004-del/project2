import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Official Satr application icon.
class AppLogoPlaceholder extends StatelessWidget {
  const AppLogoPlaceholder({super.key, this.size = 96, this.iconSize = 44});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          AppConstants.appIconAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
