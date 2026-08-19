import 'package:flutter/material.dart';

/// 4-based spacing scale used across screens and components.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;

  static const EdgeInsets page = EdgeInsets.fromLTRB(16, 16, 16, 32);
  static const EdgeInsets pageCompact = EdgeInsets.fromLTRB(16, 16, 16, 24);
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets cardCompact = EdgeInsets.all(12);
}

/// Corner radii for controls, cards, and sheets.
class AppRadii {
  AppRadii._();

  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 24;
  static const double sheet = 24;

  static BorderRadius get xsAll => BorderRadius.circular(xs);
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
  static BorderRadius get sheetTop =>
      const BorderRadius.vertical(top: Radius.circular(sheet));
}

/// Restrained elevation for light/dark surfaces.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(BuildContext context, {required bool isDark}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
        blurRadius: isDark ? 12 : 16,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }

  static List<BoxShadow> bar(BuildContext context, {required bool isDark}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.16),
        blurRadius: 18,
        offset: const Offset(0, 6),
        spreadRadius: -2,
      ),
    ];
  }
}
