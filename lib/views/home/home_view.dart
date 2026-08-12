import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/recent_uploads_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/upload_options_widget.dart';
import 'widgets/welcome_card_widget.dart';

/// Home dashboard — UI only.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
      backgroundColor: AppColors.homeBackground,
      drawer: AppDrawer(
        onHomeTap: controller.navigateHome,
        onDocumentsTap: controller.openMyDocuments,
        onSettingsTap: controller.openSettings,
      ),
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
              onMenuTap: controller.openMenu,
              onProfileTap: controller.openProfile,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ResponsiveContainer(
                  maxWidth: 720,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchBarWidget(
                        controller: controller.searchController,
                        onChanged: controller.onSearch,
                        onSubmitted: controller.onSearch,
                      ),
                      const SizedBox(height: 20),
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
                          uploads: controller.recentUploads.toList(),
                          onSeeAll: controller.openSeeAll,
                          onItemTap: controller.openUploadDetails,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
