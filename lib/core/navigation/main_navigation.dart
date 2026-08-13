import 'package:get/get.dart';

import '../../controllers/main_shell_controller.dart';
import '../../routes/app_routes.dart';
import 'main_tab.dart';

/// Shared helpers for the 3-tab primary navigation.
class MainNavigation {
  MainNavigation._();

  static const int home = MainTab.home;
  static const int pdfFiles = MainTab.pdfFiles;
  static const int settings = MainTab.settings;

  /// Switches to a main tab, returning to the shell route when needed.
  static void openTab(int index) {
    final tab = index.clamp(MainTab.home, MainTab.settings);

    if (Get.isRegistered<MainShellController>()) {
      if (Get.currentRoute != AppRoutes.home) {
        Get.until((route) => route.settings.name == AppRoutes.home);
      }
      Get.find<MainShellController>().changeTab(tab);
      return;
    }

    Get.offAllNamed(AppRoutes.home, arguments: tab);
  }
}
