import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Convenient theme accessors for screens and widgets.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get texts => theme.textTheme;

  AppSemanticColors get appColors =>
      theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  bool get isDark => theme.brightness == Brightness.dark;
}
