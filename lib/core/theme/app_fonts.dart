import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Locale-aware font families for Satr.
class AppFonts {
  AppFonts._();

  static TextStyle heading(
    TextStyle? base, {
    required bool isArabic,
  }) {
    if (isArabic) {
      return GoogleFonts.notoKufiArabic(
        textStyle: base,
      ).copyWith(
        fontFamilyFallback: const ['IBM Plex Sans Arabic', 'IBM Plex Sans'],
      );
    }
    return GoogleFonts.ibmPlexSans(textStyle: base);
  }

  static TextStyle body(
    TextStyle? base, {
    required bool isArabic,
  }) {
    if (isArabic) {
      return GoogleFonts.ibmPlexSansArabic(
        textStyle: base,
      ).copyWith(
        fontFamilyFallback: const ['IBM Plex Sans'],
      );
    }
    return GoogleFonts.ibmPlexSans(textStyle: base);
  }

  static String bodyFamily({required bool isArabic}) =>
      isArabic ? 'IBM Plex Sans Arabic' : 'IBM Plex Sans';
}
