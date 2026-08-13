import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Material 3 light/dark themes with Arabic typography and component styles.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'NotoSansArabic';
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 14;
  static const double radiusXl = 16;
  static const double buttonHeight = 48;

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkScheme : _lightScheme;
    final semantics = isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      extensions: [semantics],
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: semantics.appBarBackground,
        foregroundColor: semantics.onAppBar,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: semantics.onAppBar,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: semantics.onAppBar, size: 24),
        actionsIconTheme: IconThemeData(color: semantics.onAppBar, size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: semantics.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkElevated : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkElevated : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.darkElevated : AppColors.neutralGrayDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.15),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantics.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: semantics.mutedText,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: semantics.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: semantics.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
            color: semantics.cardBorder.withValues(alpha: 0.6),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: semantics.iconSoft,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: semantics.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
    );
  }

  static ColorScheme get _lightScheme {
    return const ColorScheme(
      brightness: Brightness.light,
      // Deep green — main actions / CTAs
      primary: AppColors.actionGreen,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: AppColors.lightIconSoft,
      onPrimaryContainer: AppColors.actionGreenDark,
      // Neutral gray — foundation / secondary UI
      secondary: AppColors.neutralGray,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE5E7EB),
      onSecondaryContainer: AppColors.neutralGrayDark,
      // Gold — limited accent
      tertiary: AppColors.accentGold,
      onTertiary: Color(0xFF1F2937),
      tertiaryContainer: AppColors.lightAccentSoft,
      onTertiaryContainer: AppColors.accentGoldDark,
      error: AppColors.error,
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerLowest: AppColors.lightScaffold,
      surfaceContainerLow: Color(0xFFF1F3F1),
      surfaceContainer: Color(0xFFEBEFEB),
      surfaceContainerHigh: Color(0xFFE5EAE5),
      surfaceContainerHighest: Color(0xFFDFE5DF),
      outline: Color(0xFFC5CBC5),
      outlineVariant: AppColors.lightBorder,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.neutralGrayDark,
      onInverseSurface: Color(0xFFF3F4F6),
      inversePrimary: AppColors.actionGreenOnDark,
    );
  }

  static ColorScheme get _darkScheme {
    return const ColorScheme(
      brightness: Brightness.dark,
      // Brighter green for contrast on dark surfaces
      primary: AppColors.actionGreenOnDark,
      onPrimary: Color(0xFFF0FDF4),
      primaryContainer: AppColors.darkBrandSoft,
      onPrimaryContainer: Color(0xFFB7E4C7),
      secondary: AppColors.neutralGrayLight,
      onSecondary: Color(0xFF121212),
      secondaryContainer: Color(0xFF3A3A3A),
      onSecondaryContainer: Color(0xFFE8E8E8),
      tertiary: AppColors.accentGoldLight,
      onTertiary: Color(0xFF1E1E1E),
      tertiaryContainer: AppColors.darkAccentSoft,
      onTertiaryContainer: AppColors.accentGoldLight,
      error: AppColors.errorDark,
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C1D18),
      onErrorContainer: Color(0xFFF9DEDC),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: AppColors.darkScaffold,
      surfaceContainerLow: Color(0xFF181818),
      surfaceContainer: AppColors.darkElevated,
      surfaceContainerHigh: Color(0xFF333333),
      surfaceContainerHighest: Color(0xFF3A3A3A),
      outline: Color(0xFF737373),
      outlineVariant: AppColors.darkBorder,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8E8E8),
      onInverseSurface: Color(0xFF1E1E1E),
      inversePrimary: AppColors.actionGreen,
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle base(double size, FontWeight weight, {double height = 1.4}) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: scheme.onSurface,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      displayLarge: base(32, FontWeight.w700, height: 1.25),
      displayMedium: base(28, FontWeight.w700, height: 1.25),
      displaySmall: base(24, FontWeight.w700, height: 1.3),
      headlineLarge: base(22, FontWeight.w700, height: 1.3),
      headlineMedium: base(20, FontWeight.w700, height: 1.3),
      headlineSmall: base(18, FontWeight.w700, height: 1.35),
      titleLarge: base(18, FontWeight.w700, height: 1.35),
      titleMedium: base(16, FontWeight.w700, height: 1.35),
      titleSmall: base(14, FontWeight.w600, height: 1.35),
      bodyLarge: base(16, FontWeight.w400, height: 1.7),
      bodyMedium: base(14, FontWeight.w400, height: 1.55),
      bodySmall: base(12, FontWeight.w400, height: 1.45),
      labelLarge: base(14, FontWeight.w600, height: 1.3),
      labelMedium: base(12, FontWeight.w600, height: 1.3),
      labelSmall: base(11, FontWeight.w600, height: 1.25),
    );
  }
}
