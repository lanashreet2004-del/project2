import 'package:flutter/material.dart';

/// Supported UI languages for Maktub.
enum AppLocale {
  arabic,
  english;

  Locale get locale {
    switch (this) {
      case AppLocale.arabic:
        return const Locale('ar');
      case AppLocale.english:
        return const Locale('en');
    }
  }

  TextDirection get textDirection {
    switch (this) {
      case AppLocale.arabic:
        return TextDirection.rtl;
      case AppLocale.english:
        return TextDirection.ltr;
    }
  }

  bool get isRtl => this == AppLocale.arabic;

  /// Native display name (not translated — always shown in its own script).
  String get nativeLabel {
    switch (this) {
      case AppLocale.arabic:
        return 'العربية';
      case AppLocale.english:
        return 'English';
    }
  }

  static AppLocale fromLanguageCode(String? code) {
    switch (code) {
      case 'en':
        return AppLocale.english;
      case 'ar':
      default:
        return AppLocale.arabic;
    }
  }

  String get languageCode {
    switch (this) {
      case AppLocale.arabic:
        return 'ar';
      case AppLocale.english:
        return 'en';
    }
  }
}
