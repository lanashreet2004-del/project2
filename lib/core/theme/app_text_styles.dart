import 'package:flutter/material.dart';

import 'app_theme_context.dart';

/// Typography helpers built on the app [TextTheme].
class AppTextStyles {
  AppTextStyles._();

  static TextStyle? display(BuildContext context) =>
      context.texts.displaySmall;

  static TextStyle? screenTitle(BuildContext context) =>
      context.texts.titleLarge;

  static TextStyle? sectionTitle(BuildContext context) =>
      context.texts.titleMedium;

  static TextStyle? body(BuildContext context) => context.texts.bodyMedium;

  static TextStyle? bodySecondary(BuildContext context) =>
      context.texts.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      );

  static TextStyle? caption(BuildContext context) =>
      context.texts.bodySmall?.copyWith(
        color: context.appColors.mutedText,
      );

  static TextStyle? button(BuildContext context) => context.texts.labelLarge;

  static TextStyle? input(BuildContext context) => context.texts.bodyLarge;

  static TextStyle? error(BuildContext context) =>
      context.texts.bodySmall?.copyWith(color: context.colors.error);

  /// Comfortable Arabic reading style for OCR text blocks.
  static TextStyle? ocrBody(BuildContext context) =>
      context.texts.bodyLarge?.copyWith(
        height: 1.85,
        letterSpacing: 0.15,
        color: context.colors.onSurface,
      );
}
