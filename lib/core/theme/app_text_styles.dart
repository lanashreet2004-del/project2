import 'package:flutter/material.dart';

/// Typography helpers built on top of Material 3 text theme.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle? headline(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium;

  static TextStyle? title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;

  static TextStyle? body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? label(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge;
}
