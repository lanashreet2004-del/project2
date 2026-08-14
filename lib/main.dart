import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/bindings/initial_binding.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_preferences.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_preferences.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final themeMode = ThemePreferences.read(storage);
    final appLocale = LocalePreferences.read(storage);

    return GetMaterialApp(
      title: 'app.name'.tr,
      onGenerateTitle: (_) => 'app.name'.tr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(isArabic: appLocale.isRtl),
      darkTheme: AppTheme.dark(isArabic: appLocale.isRtl),
      themeMode: themeMode,
      translations: AppTranslations(),
      locale: appLocale.locale,
      fallbackLocale: const Locale('en'),
      builder: (context, child) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final brightness = Theme.of(context).brightness;
        final localeTheme = brightness == Brightness.dark
            ? AppTheme.dark(isArabic: isArabic)
            : AppTheme.light(isArabic: isArabic);
        return Theme(data: localeTheme, child: child ?? const SizedBox.shrink());
      },
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
