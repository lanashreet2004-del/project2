import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/navigation/main_tab.dart';
import 'home_controller.dart';
import 'pdf_files_controller.dart';
import 'settings_controller.dart';

/// Controls the primary bottom-navigation shell tabs.
class MainShellController extends GetxController {
  final RxInt currentIndex = MainTab.home.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      currentIndex.value = args.clamp(MainTab.home, MainTab.settings);
    } else if (args is Map && args['tab'] is int) {
      currentIndex.value =
          (args['tab'] as int).clamp(MainTab.home, MainTab.settings);
    }
  }

  void changeTab(int index) {
    final next = index.clamp(MainTab.home, MainTab.settings);
    if (currentIndex.value == next) {
      _onReselect(next);
      return;
    }

    currentIndex.value = next;
    _onTabVisible(next);
  }

  void _onTabVisible(int index) {
    if (index == MainTab.pdfFiles && Get.isRegistered<PdfFilesController>()) {
      Get.find<PdfFilesController>().loadPdfFiles();
    }
    if (index == MainTab.settings && Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().refreshAccountState();
    }
  }

  void _onReselect(int index) {
    if (index == MainTab.home && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadDocuments();
    }
    if (index == MainTab.pdfFiles && Get.isRegistered<PdfFilesController>()) {
      Get.find<PdfFilesController>().loadPdfFiles();
    }
  }

  /// Android back: return to Home tab first, then leave the app.
  Future<bool> handleSystemBack() async {
    if (currentIndex.value != MainTab.home) {
      changeTab(MainTab.home);
      return false;
    }
    await SystemNavigator.pop();
    return false;
  }
}
