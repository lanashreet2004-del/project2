import '../constants/storage_keys.dart';
import '../services/storage_service.dart';
import 'app_locale.dart';

/// Reads/writes persisted [AppLocale] via GetStorage.
class LocalePreferences {
  LocalePreferences._();

  /// Defaults to Arabic when no preference is saved.
  static AppLocale read(StorageService storage) {
    final stored = storage.read<String>(StorageKeys.locale);
    return AppLocale.fromLanguageCode(stored);
  }

  static Future<void> write(StorageService storage, AppLocale locale) async {
    await storage.write(StorageKeys.locale, locale.languageCode);
  }
}
