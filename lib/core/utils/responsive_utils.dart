import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Screen size classification for responsive layouts.
enum ScreenType { mobile, tablet, desktop }

/// Utility methods for responsive design decisions.
class ResponsiveUtils {
  ResponsiveUtils._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static ScreenType screenType(BuildContext context) {
    final width = screenWidth(context);
    if (width >= AppConstants.desktopBreakpoint) return ScreenType.desktop;
    if (width >= AppConstants.tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      screenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      screenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      screenType(context) == ScreenType.desktop;

  /// Returns [mobile] on small screens, [tablet] on medium, [desktop] on large.
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (screenType(context)) {
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.mobile:
        return mobile;
    }
  }
}
