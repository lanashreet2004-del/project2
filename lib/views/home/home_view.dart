import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/main_shell_controller.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/navigation/main_tab.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/recent_uploads_widget.dart';
import 'widgets/upload_options_widget.dart';
import 'widgets/welcome_card_widget.dart';

/// Home dashboard — UI only.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  DrawerDestination? get _selectedDrawerDestination {
    if (!Get.isRegistered<MainShellController>()) return null;
    final tab = Get.find<MainShellController>().currentIndex.value;
    if (tab == MainTab.pdfFiles) return DrawerDestination.pdfFiles;
    if (tab == MainTab.settings) return DrawerDestination.settings;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value<double>(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: context.colors.surfaceContainerLowest,
      drawer: Obx(
        () {
          // Depend on shell tab + language for selected highlight / labels.
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().currentIndex.value;
          }
          if (Get.isRegistered<LocaleController>()) {
            Get.find<LocaleController>().current.value;
          }
          return AppDrawer(
            displayName: controller.username.value == 'common.guest'
                ? 'common.guest'.tr
                : controller.username.value,
            email: controller.userEmail.value,
            isLoggedIn: controller.isLoggedIn.value,
            isDarkMode: controller.isDarkMode.value,
            selectedDestination: _selectedDrawerDestination,
            onDocumentsTap: controller.openMyDocuments,
            onPdfFilesTap: controller.openPdfFiles,
            onWordFilesTap: controller.openWordFiles,
            onExcelFilesTap: controller.openExcelFiles,
            onJsonFilesTap: controller.openJsonFiles,
            onSettingsTap: controller.openSettings,
            onDarkModeChanged: controller.setDrawerDarkMode,
            onSignInTap: controller.openSignInFromDrawer,
            onSignOutTap: controller.signOutFromDrawer,
            onHeaderTap: controller.openProfile,
          );
        },
      ),
      body: Column(
        children: [
          HomeAppBar(
            onMenuTap: controller.openMenu,
            onProfileTap: controller.openSettings,
            searchController: controller.searchEntryController,
            onSearchTap: controller.openSearch,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: RefreshIndicator(
                onRefresh: controller.refreshHome,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ResponsiveContainer(
                    maxWidth: 720,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Obx(
                          () => WelcomeCardWidget(
                            greeting: controller.greeting.value,
                            username: controller.username.value,
                          ),
                        ),
                        const SizedBox(height: 24),
                        UploadOptionsWidget(
                          onGalleryTap: controller.pickFromGallery,
                          onCameraTap: controller.pickFromCamera,
                          onDocumentsTap: controller.openMyDocuments,
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => RecentUploadsWidget(
                            documents: controller.recentDocuments.toList(),
                            onSeeAll: controller.openSeeAll,
                            onItemTap: controller.openDocument,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
