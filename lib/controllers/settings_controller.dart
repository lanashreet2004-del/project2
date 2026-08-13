import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/storage_service.dart';
import '../core/theme/theme_preferences.dart';
import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'home_controller.dart';

/// Controller for app settings and preferences.
class SettingsController extends BaseController {
  SettingsController({
    required StorageService storageService,
    required AuthRepository authRepository,
  })  : _storageService = storageService,
        _authRepository = authRepository;

  final StorageService _storageService;
  final AuthRepository _authRepository;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxBool isLoggedIn = false.obs;
  final RxnString userEmail = RxnString();
  final RxnString userName = RxnString();

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    refreshAccountState();
  }

  void _loadPreferences() {
    themeMode.value = ThemePreferences.read(_storageService);
    _applyTheme();
  }

  void refreshAccountState() {
    isLoggedIn.value = _authRepository.isLoggedIn;
    final user = _authRepository.getCurrentUser();
    userEmail.value = user?.email;
    userName.value = user?.name;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value == mode) return;
    themeMode.value = mode;
    await ThemePreferences.write(_storageService, mode);
    _applyTheme();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().isDarkMode.value = mode == ThemeMode.dark ||
          (mode == ThemeMode.system && Get.isPlatformDarkMode);
    }
  }

  /// Kept for compatibility with older call sites.
  Future<void> toggleDarkMode() async {
    final next = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  void _applyTheme() {
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('settings.signOutTitle'.tr),
        content: Text('settings.signOutBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'drawer.signOut'.tr,
              style: TextStyle(color: Get.theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authRepository.signOut();
    refreshAccountState();
    Get.snackbar(
      'settings.signedOutTitle'.tr,
      'settings.signedOutBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> openAccount() async {
    await Get.toNamed(AppRoutes.profile);
    refreshAccountState();
  }
}
