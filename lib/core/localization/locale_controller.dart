import 'package:get/get.dart';

import '../services/storage_service.dart';
import 'app_locale.dart';
import 'locale_preferences.dart';

/// Single source of truth for app language (Settings + Drawer).
class LocaleController extends GetxController {
  LocaleController({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  final Rx<AppLocale> current = AppLocale.arabic.obs;

  @override
  void onInit() {
    super.onInit();
    current.value = LocalePreferences.read(_storageService);
  }

  Future<void> setLocale(AppLocale locale) async {
    if (current.value == locale) return;
    current.value = locale;
    await LocalePreferences.write(_storageService, locale);
    Get.updateLocale(locale.locale);
  }
}
