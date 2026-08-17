import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';
import '../../../core/widgets/language_selector.dart';

enum DrawerDestination {
  documents,
  pdfFiles,
  wordFiles,
  excelFiles,
  jsonFiles,
  settings,
}

/// Home drawer — secondary access to documents, export libraries, settings, theme, language, auth.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.displayName,
    required this.email,
    required this.isLoggedIn,
    required this.isDarkMode,
    required this.selectedDestination,
    required this.onDocumentsTap,
    required this.onPdfFilesTap,
    required this.onWordFilesTap,
    required this.onExcelFilesTap,
    required this.onJsonFilesTap,
    required this.onSettingsTap,
    required this.onDarkModeChanged,
    required this.onSignInTap,
    required this.onSignOutTap,
    this.onHeaderTap,
  });

  final String displayName;
  final String? email;
  final bool isLoggedIn;
  final bool isDarkMode;
  final DrawerDestination? selectedDestination;
  final VoidCallback onDocumentsTap;
  final VoidCallback onPdfFilesTap;
  final VoidCallback onWordFilesTap;
  final VoidCallback onExcelFilesTap;
  final VoidCallback onJsonFilesTap;
  final VoidCallback onSettingsTap;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onSignInTap;
  final VoidCallback onSignOutTap;
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = isLoggedIn
        ? (email?.trim().isNotEmpty == true ? email! : 'common.signedIn'.tr)
        : 'drawer.guestSubtitle'.tr;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: context.colors.primary,
              child: InkWell(
                onTap: onHeaderTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            context.colors.onPrimary.withValues(alpha: 0.18),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: context.colors.onPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.titleMedium?.copyWith(
                                color: context.colors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.bodySmall?.copyWith(
                                color: context.colors.onPrimary
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerNavTile(
                    icon: Icons.folder_outlined,
                    selectedIcon: Icons.folder_rounded,
                    label: 'nav.myDocuments'.tr,
                    selected:
                        selectedDestination == DrawerDestination.documents,
                    onTap: onDocumentsTap,
                  ),
                  _DrawerNavTile(
                    icon: Icons.picture_as_pdf_outlined,
                    selectedIcon: Icons.picture_as_pdf_rounded,
                    label: 'nav.pdfFiles'.tr,
                    selected:
                        selectedDestination == DrawerDestination.pdfFiles,
                    onTap: onPdfFilesTap,
                  ),
                  _DrawerNavTile(
                    icon: Icons.description_outlined,
                    selectedIcon: Icons.description_rounded,
                    label: 'nav.wordFiles'.tr,
                    selected:
                        selectedDestination == DrawerDestination.wordFiles,
                    onTap: onWordFilesTap,
                  ),
                  _DrawerNavTile(
                    icon: Icons.table_chart_outlined,
                    selectedIcon: Icons.table_chart_rounded,
                    label: 'nav.excelFiles'.tr,
                    selected:
                        selectedDestination == DrawerDestination.excelFiles,
                    onTap: onExcelFilesTap,
                  ),
                  _DrawerNavTile(
                    icon: Icons.data_object_outlined,
                    selectedIcon: Icons.data_object_rounded,
                    label: 'nav.jsonFiles'.tr,
                    selected:
                        selectedDestination == DrawerDestination.jsonFiles,
                    onTap: onJsonFilesTap,
                  ),
                  _DrawerNavTile(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    label: 'nav.settings'.tr,
                    selected:
                        selectedDestination == DrawerDestination.settings,
                    onTap: onSettingsTap,
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    height: 1,
                    color: context.appColors.cardBorder,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Text(
                      'drawer.appearance'.tr,
                      style: context.texts.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    secondary: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: context.colors.primary,
                    ),
                    title: Text(
                      isDarkMode
                          ? 'drawer.darkMode'.tr
                          : 'drawer.lightMode'.tr,
                      style: context.texts.titleSmall,
                    ),
                    subtitle: Text(
                      isDarkMode ? 'common.on'.tr : 'common.off'.tr,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    value: isDarkMode,
                    onChanged: onDarkModeChanged,
                  ),
                  const LanguageSelector(compact: true),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: context.appColors.cardBorder,
            ),
            if (isLoggedIn)
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: context.colors.error.withValues(alpha: 0.9),
                ),
                title: Text(
                  'drawer.signOut'.tr,
                  style: context.texts.titleSmall?.copyWith(
                    color: context.colors.error.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onSignOutTap,
              )
            else
              ListTile(
                leading: Icon(
                  Icons.login_rounded,
                  color: context.colors.primary,
                ),
                title: Text(
                  'drawer.signIn'.tr,
                  style: context.texts.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: onSignInTap,
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? context.colors.primary
        : context.colors.onSurface;
    final bg = selected
        ? context.colors.primary.withValues(alpha: 0.10)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: bg,
        leading: Icon(
          selected ? selectedIcon : icon,
          color: fg,
        ),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.titleSmall?.copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
