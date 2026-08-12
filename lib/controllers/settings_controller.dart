import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/storage_keys.dart';
import '../core/services/storage_service.dart';
import 'base_controller.dart';

/// Controller for app settings and preferences.
class SettingsController extends BaseController {
  SettingsController({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  void _loadPreferences() {
    isDarkMode.value =
        _storageService.read<bool>(StorageKeys.darkMode) ?? false;
    _applyTheme();
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    await _storageService.write(StorageKeys.darkMode, isDarkMode.value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
