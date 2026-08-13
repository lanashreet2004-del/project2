import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../localization/app_locale.dart';
import '../localization/locale_controller.dart';
import '../theme/app_theme_context.dart';

/// Compact Arabic / English language control (Settings + Drawer).
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    this.compact = false,
  });

  /// When true, hides the section title (drawer already has a header).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return Obx(() {
      final selected = localeController.current.value;

      final selector = SegmentedButton<AppLocale>(
        segments: [
          ButtonSegment(
            value: AppLocale.arabic,
            label: Text(
              AppLocale.arabic.nativeLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ButtonSegment(
            value: AppLocale.english,
            label: Text(
              AppLocale.english.nativeLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          localeController.setLocale(selection.first);
        },
        style: ButtonStyle(
          visualDensity: compact ? VisualDensity.compact : null,
          textStyle: WidgetStatePropertyAll(
            context.texts.labelLarge,
          ),
        ),
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'drawer.language'.tr,
                style: context.texts.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: selector,
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.language'.tr,
            style: context.texts.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'settings.languageHint'.tr,
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          selector,
        ],
      );
    });
  }
}
