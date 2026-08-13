import 'package:flutter/material.dart';

/// Brand and status color tokens used to build [ColorScheme] / theme extensions.
///
/// Visual identity:
/// - Gray → foundation / neutral UI
/// - Deep green → main actions (Material [ColorScheme.primary])
/// - Gold → limited accent (Material [ColorScheme.tertiary])
class AppColors {
  AppColors._();

  // ── Action green (Material primary) ─────────────────────────────
  static const Color actionGreen = Color(0xFF14532D);
  static const Color actionGreenLight = Color(0xFF166534);
  static const Color actionGreenDark = Color(0xFF0F3D23);
  /// Slightly brighter green for dark-theme interactive elements.
  static const Color actionGreenOnDark = Color(0xFF2F6B45);

  // ── Neutral gray foundation (Material secondary) ────────────────
  static const Color neutralGray = Color(0xFF4B5563);
  static const Color neutralGrayLight = Color(0xFF6B7280);
  static const Color neutralGrayDark = Color(0xFF374151);

  // ── Elegant gold accent (Material tertiary) ─────────────────────
  static const Color accentGold = Color(0xFFC9A227);
  static const Color accentGoldLight = Color(0xFFD8B84C);
  static const Color accentGoldDark = Color(0xFFA88416);

  // Status
  static const Color success = Color(0xFF166534);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFB45309);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color error = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFF2B8B5);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoDark = Color(0xFF60A5FA);

  // Light surfaces
  static const Color lightScaffold = Color(0xFFF7F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color lightInput = Color(0xFFFFFFFF);
  static const Color lightBrandSoft = Color(0xFFE8F0EA);
  static const Color lightIconSoft = Color(0xFFEDF2EE);
  static const Color lightAccentSoft = Color(0xFFF7F1DF);
  static const Color lightBorder = Color(0xFFE2E6E3);
  /// Soft brand-green outline for cards.
  static const Color lightCardBorder = Color(0xFFA8C4B0);
  static const Color lightDivider = Color(0xFFE8ECE9);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // Dark surfaces (neutral charcoal / dark gray — not blue-slate)
  static const Color darkScaffold = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkElevated = Color(0xFF2A2A2A);
  static const Color darkInput = Color(0xFF2A2A2A);
  static const Color darkBrandSoft = Color(0xFF1A2E24);
  static const Color darkIconSoft = Color(0xFF24352C);
  static const Color darkAccentSoft = Color(0xFF3A3420);
  static const Color darkBorder = Color(0xFF3A3A3A);
  /// Soft brand-green outline for cards (dark theme).
  static const Color darkCardBorder = Color(0xFF3D5A48);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);
  static const Color darkTextMuted = Color(0xFF737373);

  // Compatibility aliases (prefer ColorScheme / AppSemanticColors)
  static const Color brandPrimary = actionGreen;
  static const Color brandPrimaryLight = actionGreenOnDark;
  static const Color brandPrimaryDark = actionGreenDark;
  static const Color seedColor = actionGreen;
  static const Color accent = accentGold;
  static const Color accentLight = accentGoldLight;
  static const Color homeBackground = lightScaffold;
  static const Color welcomeCardBg = lightBrandSoft;
  static const Color cardBorder = lightCardBorder;
  static const Color textSecondary = lightTextSecondary;
  static const Color iconBgPurple = lightIconSoft;
  static const Color nameHighlight = actionGreen;
}

/// App-specific semantic colors beyond Material [ColorScheme].
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.brandSoft,
    required this.iconSoft,
    required this.accent,
    required this.accentSoft,
    required this.appBarBackground,
    required this.onAppBar,
    required this.elevatedSurface,
    required this.inputFill,
    required this.cardBorder,
    required this.mutedText,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color brandSoft;
  final Color iconSoft;
  final Color accent;
  final Color accentSoft;
  final Color appBarBackground;
  final Color onAppBar;
  final Color elevatedSurface;
  final Color inputFill;
  final Color cardBorder;
  final Color mutedText;

  static const light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: Color(0xFFFFFFFF),
    warning: AppColors.warning,
    onWarning: Color(0xFFFFFFFF),
    info: AppColors.info,
    onInfo: Color(0xFFFFFFFF),
    brandSoft: AppColors.lightBrandSoft,
    iconSoft: AppColors.lightIconSoft,
    accent: AppColors.accentGold,
    accentSoft: AppColors.lightAccentSoft,
    appBarBackground: AppColors.actionGreen,
    onAppBar: Color(0xFFFFFFFF),
    elevatedSurface: AppColors.lightElevated,
    inputFill: AppColors.lightInput,
    cardBorder: AppColors.lightCardBorder,
    mutedText: AppColors.lightTextMuted,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    onSuccess: Color(0xFF052E16),
    warning: AppColors.warningDark,
    onWarning: Color(0xFF2A1600),
    info: AppColors.infoDark,
    onInfo: Color(0xFF001F2A),
    brandSoft: AppColors.darkBrandSoft,
    iconSoft: AppColors.darkIconSoft,
    accent: AppColors.accentGoldLight,
    accentSoft: AppColors.darkAccentSoft,
    appBarBackground: AppColors.actionGreenDark,
    onAppBar: Color(0xFFFFFFFF),
    elevatedSurface: AppColors.darkElevated,
    inputFill: AppColors.darkInput,
    cardBorder: AppColors.darkCardBorder,
    mutedText: AppColors.darkTextMuted,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? brandSoft,
    Color? iconSoft,
    Color? accent,
    Color? accentSoft,
    Color? appBarBackground,
    Color? onAppBar,
    Color? elevatedSurface,
    Color? inputFill,
    Color? cardBorder,
    Color? mutedText,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      brandSoft: brandSoft ?? this.brandSoft,
      iconSoft: iconSoft ?? this.iconSoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      onAppBar: onAppBar ?? this.onAppBar,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      inputFill: inputFill ?? this.inputFill,
      cardBorder: cardBorder ?? this.cardBorder,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      iconSoft: Color.lerp(iconSoft, other.iconSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,
      onAppBar: Color.lerp(onAppBar, other.onAppBar, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }
}
