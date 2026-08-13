import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/navigation/main_navigation.dart';
import '../core/services/storage_service.dart';
import '../core/theme/theme_preferences.dart';
import '../models/history_model.dart';
import '../models/image_pick_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/history_repository.dart';
import '../repositories/image_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'settings_controller.dart';

/// Controller for home screen presentation logic.
class HomeController extends BaseController {
  HomeController({
    required AuthRepository authRepository,
    required ImageRepository imageRepository,
    required HistoryRepository historyRepository,
    required StorageService storageService,
  })  : _authRepository = authRepository,
        _imageRepository = imageRepository,
        _historyRepository = historyRepository,
        _storageService = storageService;

  final AuthRepository _authRepository;
  final ImageRepository _imageRepository;
  final HistoryRepository _historyRepository;
  final StorageService _storageService;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RxString username = 'common.guest'.obs;
  final RxnString userEmail = RxnString();
  final RxBool isLoggedIn = false.obs;
  final RxString greeting = 'home.greetingMorning'.obs;
  final RxList<HistoryModel> allDocuments = <HistoryModel>[].obs;
  final RxList<HistoryModel> recentDocuments = <HistoryModel>[].obs;
  final RxBool isDarkMode = false.obs;

  /// Display-only field used as the Home search entry (opens Search page).
  final TextEditingController searchEntryController = TextEditingController();

  static const int _recentLimit = 5;

  @override
  void onInit() {
    super.onInit();
    _setGreeting();
    _loadUserIdentity();
    syncDarkModeFromPreferences();
    loadDocuments();
  }

  void syncDarkModeFromPreferences() {
    final mode = ThemePreferences.read(_storageService);
    if (mode == ThemeMode.system) {
      isDarkMode.value = Get.isPlatformDarkMode;
    } else {
      isDarkMode.value = mode == ThemeMode.dark;
    }
  }

  Future<void> setDrawerDarkMode(bool enabled) async {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    isDarkMode.value = enabled;
    await ThemePreferences.write(_storageService, mode);
    Get.changeThemeMode(mode);

    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().themeMode.value = mode;
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadDocuments();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'home.greetingMorning';
    } else if (hour < 17) {
      greeting.value = 'home.greetingAfternoon';
    } else {
      greeting.value = 'home.greetingEvening';
    }
  }

  void _loadUserIdentity() {
    final user = _authRepository.getCurrentUser();
    isLoggedIn.value = _authRepository.isLoggedIn;
    if (user != null) {
      username.value = user.name?.trim().isNotEmpty == true
          ? user.name!
          : user.email.split('@').first;
      userEmail.value = user.email;
    } else {
      username.value = 'common.guest';
      userEmail.value = null;
    }
  }

  Future<void> loadDocuments() async {
    _loadUserIdentity();
    final data = await runAsync(() => _historyRepository.getDocuments());
    if (data == null) return;

    allDocuments.assignAll(data);
    _applyRecentDocuments();
  }

  void _applyRecentDocuments() {
    final limit =
        allDocuments.length < _recentLimit ? allDocuments.length : _recentLimit;
    recentDocuments.assignAll(allDocuments.take(limit).toList());
  }

  Future<void> refreshHome() => loadDocuments();

  void _openImageEditor(String path, ImagePickSource source) {
    Get.toNamed(
      AppRoutes.imageEditor,
      arguments: {
        'filePath': path,
        'source': source.routeValue,
      },
    )?.then((_) => loadDocuments());
  }

  Future<void> pickFromGallery() async {
    final path = await runAsync(() => _imageRepository.pickFromGallery());
    if (path != null) {
      _openImageEditor(path, ImagePickSource.gallery);
    } else if (hasError) {
      _showPickError('home.gallery'.tr);
    }
  }

  Future<void> pickFromCamera() async {
    final path = await runAsync(() => _imageRepository.pickFromCamera());
    if (path != null) {
      _openImageEditor(path, ImagePickSource.camera);
    } else if (hasError) {
      _showPickError('home.camera'.tr);
    }
  }

  void _showPickError(String source) {
    Get.snackbar(
      source,
      errorMessage.value ?? 'home.pickFailed'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  void openMenu() {
    _loadUserIdentity();
    syncDarkModeFromPreferences();
    scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  void navigateHome() {
    _closeDrawer();
    MainNavigation.openTab(MainNavigation.home);
  }

  Future<void> openMyDocuments() async {
    _closeDrawer();
    await Get.toNamed(AppRoutes.documents);
    await loadDocuments();
  }

  void openPdfFiles() {
    _closeDrawer();
    MainNavigation.openTab(MainNavigation.pdfFiles);
  }

  Future<void> openJsonFiles() async {
    _closeDrawer();
    await Get.toNamed(AppRoutes.jsonFiles);
  }

  Future<void> openWordFiles() async {
    _closeDrawer();
    await Get.toNamed(AppRoutes.wordFiles);
  }

  void openSettings() {
    _closeDrawer();
    MainNavigation.openTab(MainNavigation.settings);
  }

  Future<void> openProfile() async {
    _closeDrawer();
    await Get.toNamed(AppRoutes.profile);
    _loadUserIdentity();
    await loadDocuments();
  }

  Future<void> openSignInFromDrawer() async {
    _closeDrawer();
    await Get.toNamed(AppRoutes.auth);
    _loadUserIdentity();
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().refreshAccountState();
    }
  }

  Future<void> signOutFromDrawer() async {
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

    _closeDrawer();
    await _authRepository.signOut();
    _loadUserIdentity();
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().refreshAccountState();
    }
    Get.snackbar(
      'settings.signedOutTitle'.tr,
      'settings.signedOutBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> openSearch() async {
    await Get.toNamed(AppRoutes.search);
    await loadDocuments();
  }

  Future<void> openDocument(HistoryModel document) async {
    await Get.toNamed(AppRoutes.documentDetails, arguments: document);
    await loadDocuments();
  }

  Future<void> openSeeAll() async {
    await Get.toNamed(AppRoutes.documents);
    await loadDocuments();
  }

  static String documentTitle(HistoryModel document) {
    final trimmed = document.extractedText.trim();
    if (trimmed.isEmpty) return 'common.untitledDocument'.tr;

    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.isEmpty) return 'common.untitledDocument'.tr;

    const maxLength = 48;
    if (firstLine.length <= maxLength) return firstLine;
    return '${firstLine.substring(0, maxLength)}...';
  }

  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'home.timeJustNow'.tr;
    if (diff.inMinutes < 60) {
      return 'home.timeMinutes'.trParams({'count': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) {
      return 'home.timeHours'.trParams({'count': '${diff.inHours}'});
    }
    if (diff.inDays == 1) return 'home.timeYesterday'.tr;
    if (diff.inDays < 7) {
      return 'home.timeDays'.trParams({'count': '${diff.inDays}'});
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  static bool hasLocalImage(HistoryModel document) {
    if (document.imagePath.isEmpty) return false;
    return File(document.imagePath).existsSync();
  }

  @override
  void onClose() {
    searchEntryController.dispose();
    super.onClose();
  }
}
