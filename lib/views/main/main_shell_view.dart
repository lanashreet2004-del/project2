import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_shell_controller.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/navigation/main_navigation.dart';
import '../home/home_view.dart';
import '../pdf_files/pdf_files_view.dart';
import '../settings/settings_view.dart';
import 'widgets/maktub_bottom_nav_bar.dart';

/// Primary app shell: Home | PDF Files | Settings.
class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Rebuild nav labels when language changes.
      Get.find<LocaleController>().current.value;

      final items = [
        MaktubBottomNavItem(
          label: 'nav.home'.tr,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
        MaktubBottomNavItem(
          label: 'nav.pdfFiles'.tr,
          icon: Icons.picture_as_pdf_outlined,
          selectedIcon: Icons.picture_as_pdf_rounded,
        ),
        MaktubBottomNavItem(
          label: 'nav.settings'.tr,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
        ),
      ];

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await controller.handleSystemBack();
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              PdfFilesView(),
              SettingsView(),
            ],
          ),
          bottomNavigationBar: MaktubBottomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            items: items,
          ),
        ),
      );
    });
  }
}

/// Redirects legacy `/pdf-files` and `/settings` routes into the shell.
class MainTabLaunchView extends StatefulWidget {
  const MainTabLaunchView({super.key, required this.tabIndex});

  final int tabIndex;

  @override
  State<MainTabLaunchView> createState() => _MainTabLaunchViewState();
}

class _MainTabLaunchViewState extends State<MainTabLaunchView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainNavigation.openTab(widget.tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
