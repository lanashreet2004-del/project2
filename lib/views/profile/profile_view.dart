import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';

/// Simple frontend account screen — no real backend auth.
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('profile.title'.tr),
      ),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Obx(() {
          final loggedIn = controller.isLoggedIn.value;
          final user = controller.user.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.appColors.iconSoft,
                      child: Icon(
                        Icons.person_outline,
                        color: context.colors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loggedIn
                                ? (user?.name ?? 'common.user'.tr)
                                : 'common.guest'.tr,
                            style: context.texts.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loggedIn
                                ? (user?.email ?? '')
                                : 'profile.notSignedIn'.tr,
                            style: context.texts.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appColors.brandSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loggedIn
                      ? 'profile.signedInNotice'.tr
                      : 'profile.guestNotice'.tr,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text('profile.status'.tr),
                      subtitle: Text(
                        loggedIn
                            ? 'profile.localSession'.tr
                            : 'common.guest'.tr,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text('nav.settings'.tr),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: controller.openSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!loggedIn)
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: controller.openSignIn,
                    icon: const Icon(Icons.login),
                    label: Text('drawer.signIn'.tr),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: controller.signOut,
                    icon: const Icon(Icons.logout),
                    label: Text('drawer.signOut'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.error,
                      side: BorderSide(
                        color: context.colors.error.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
