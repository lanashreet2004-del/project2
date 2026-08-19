import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_spacing.dart';

/// Material 3 light/dark themes with locale-aware typography and component styles.
class AppTheme {
  AppTheme._();

  static const double radiusSm = AppRadii.sm;
  static const double radiusMd = AppRadii.md;
  static const double radiusLg = 14;
  static const double radiusXl = AppRadii.lg;
  static const double buttonHeight = 52;

  static ThemeData light({required bool isArabic}) =>
      _build(Brightness.light, isArabic: isArabic);

  static ThemeData dark({required bool isArabic}) =>
      _build(Brightness.dark, isArabic: isArabic);

  static ThemeData _build(Brightness brightness, {required bool isArabic}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkScheme : _lightScheme;
    final semantics = isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    final textTheme = _textTheme(colorScheme, isArabic: isArabic);
    final bodyFamily = AppFonts.bodyFamily(isArabic: isArabic);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: bodyFamily,
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
        clipBehavior: Clip.antiAlias,
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
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkElevated : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.sheetTop,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minVerticalPadding: 10,
        titleTextStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.35,
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
          minimumSize: const Size(48, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, buttonHeight),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, buttonHeight),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
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
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.darkElevated : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 4,
        textStyle: textTheme.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevated : AppColors.neutralGrayDark,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: Colors.white),
        waitDuration: const Duration(milliseconds: 400),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            isDark ? AppColors.darkElevated : colorScheme.surface,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
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

  static TextTheme _textTheme(ColorScheme scheme, {required bool isArabic}) {
    TextStyle base(
      double size,
      FontWeight weight, {
      double height = 1.4,
      required bool heading,
    }) {
      final style = TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: scheme.onSurface,
        letterSpacing: 0,
      );
      return heading
          ? AppFonts.heading(style, isArabic: isArabic)
          : AppFonts.body(style, isArabic: isArabic);
    }

    return TextTheme(
      displayLarge: base(32, FontWeight.w700, height: 1.25, heading: true),
      displayMedium: base(28, FontWeight.w700, height: 1.25, heading: true),
      displaySmall: base(24, FontWeight.w700, height: 1.3, heading: true),
      headlineLarge: base(22, FontWeight.w700, height: 1.3, heading: true),
      headlineMedium: base(20, FontWeight.w700, height: 1.3, heading: true),
      headlineSmall: base(18, FontWeight.w700, height: 1.35, heading: true),
      titleLarge: base(18, FontWeight.w700, height: 1.35, heading: true),
      titleMedium: base(16, FontWeight.w700, height: 1.35, heading: true),
      titleSmall: base(14, FontWeight.w600, height: 1.35, heading: false),
      bodyLarge: base(16, FontWeight.w400, height: 1.7, heading: false),
      bodyMedium: base(14, FontWeight.w400, height: 1.55, heading: false),
      bodySmall: base(12, FontWeight.w400, height: 1.45, heading: false),
      labelLarge: base(14, FontWeight.w600, height: 1.3, heading: false),
      labelMedium: base(12, FontWeight.w600, height: 1.3, heading: false),
      labelSmall: base(11, FontWeight.w600, height: 1.25, heading: false),
    );
  }
}
