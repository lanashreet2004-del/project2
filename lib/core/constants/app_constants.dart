/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Satr';
  static const String appDisplayName = 'Satr';
  static const String appTagline = 'SATR • OCR';
  static const String appIconAsset = 'assets/images/branding/app_icon.png';
  static const String appVersion = '1.0.0';

  // Onboarding assets
  static const String onboardingImage1 = 'assets/images/splash/splash1.png';
  static const String onboardingImage2 = 'assets/images/splash/splash2.png';
  static const String onboardingImage3 = 'assets/images/splash/splash3.png';

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(milliseconds: 1800);
}
