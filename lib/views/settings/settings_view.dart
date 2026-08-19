import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/theme/theme_preferences.dart';
import '../../core/widgets/language_selector.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../../routes/app_routes.dart';

/// Settings screen — account, appearance, language, about.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('settings.title'.tr),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Obx(
          () {
            // Rebuild when language changes (Settings language selector).
            if (Get.isRegistered<LocaleController>()) {
              Get.find<LocaleController>().current.value;
            }
            return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'settings.account'.tr,
                style: context.texts.titleSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: context.appColors.iconSoft,
                        child: Icon(
                          Icons.person_outline,
                          color: context.colors.primary,
                        ),
                      ),
                      title: Text(
                        controller.isLoggedIn.value
                            ? (controller.userName.value?.trim().isNotEmpty ==
                                    true
                                ? controller.userName.value!
                                : 'common.user'.tr)
                            : 'common.guest'.tr,
                        style: context.texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        controller.isLoggedIn.value
                            ? (controller.userEmail.value ??
                                'common.signedIn'.tr)
                            : 'settings.accountManage'.tr,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: controller.openAccount,
                    ),
                    const Divider(height: 1),
                    if (controller.isLoggedIn.value)
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: context.colors.error,
                        ),
                        title: Text(
                          'drawer.signOut'.tr,
                          style: TextStyle(color: context.colors.error),
                        ),
                        onTap: controller.signOut,
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: Text('drawer.signIn'.tr),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Get.toNamed(AppRoutes.auth),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings.appearance'.tr,
                style: context.texts.titleSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'settings.theme'.tr,
                        style: context.texts.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'settings.themeHint'.tr,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('settings.themeLight'.tr),
                            icon: const Icon(Icons.light_mode_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('settings.themeDark'.tr),
                            icon: const Icon(Icons.dark_mode_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('settings.themeSystem'.tr),
                            icon: const Icon(
                              Icons.settings_suggest_outlined,
                              size: 18,
                            ),
                          ),
                        ],
                        selected: {controller.themeMode.value},
                        onSelectionChanged: (selection) {
                          if (selection.isEmpty) return;
                          controller.setThemeMode(selection.first);
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'settings.themeCurrent'.trParams({
                          'theme': ThemePreferences.label(
                            controller.themeMode.value,
                          ),
                        }),
                        style: context.texts.labelMedium?.copyWith(
                          color: context.appColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings.language'.tr,
                style: context.texts.titleSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              const Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: LanguageSelector(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings.about'.tr,
                style: context.texts.titleSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('settings.aboutApp'.tr),
                  subtitle: Text(
                    '${'app.name'.tr} • Version ${AppConstants.appVersion}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'settings.demoNotice'.tr,
                style: context.texts.bodySmall?.copyWith(
                  color: context.appColors.mutedText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
          },
        ),
      ),
    );
  }
}
