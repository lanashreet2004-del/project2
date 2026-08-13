import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../services/storage_service.dart';

/// Reads/writes persisted [ThemeMode] with legacy dark_mode migration.
class ThemePreferences {
  ThemePreferences._();

  static const light = 'light';
  static const dark = 'dark';
  static const system = 'system';

  static ThemeMode read(StorageService storage) {
    final stored = storage.read<String>(StorageKeys.themeMode);
    if (stored != null) {
      return fromStorageValue(stored);
    }

    // Migrate legacy boolean preference once.
    final legacyDark = storage.read<bool>(StorageKeys.darkMode);
    if (legacyDark != null) {
      final mode = legacyDark ? ThemeMode.dark : ThemeMode.light;
      storage.write(StorageKeys.themeMode, toStorageValue(mode));
      return mode;
    }

    return ThemeMode.system;
  }

  static Future<void> write(StorageService storage, ThemeMode mode) async {
    await storage.write(StorageKeys.themeMode, toStorageValue(mode));
    // Keep legacy key in sync for older readers.
    await storage.write(StorageKeys.darkMode, mode == ThemeMode.dark);
  }

  static ThemeMode fromStorageValue(String value) {
    switch (value) {
      case dark:
        return ThemeMode.dark;
      case system:
        return ThemeMode.system;
      case light:
      default:
        return ThemeMode.light;
    }
  }

  static String toStorageValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return dark;
      case ThemeMode.system:
        return system;
      case ThemeMode.light:
        return light;
    }
  }

  static String label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'settings.themeDark'.tr;
      case ThemeMode.system:
        return 'settings.themeSystem'.tr;
      case ThemeMode.light:
        return 'settings.themeLight'.tr;
    }
  }
}
