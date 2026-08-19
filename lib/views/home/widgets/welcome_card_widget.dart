import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_context.dart';
import 'sun_illustration.dart';

/// Welcome greeting card with dynamic username.
class WelcomeCardWidget extends StatelessWidget {
  const WelcomeCardWidget({
    super.key,
    required this.greeting,
    required this.username,
  });

  final String greeting;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: context.appColors.brandSoft,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: context.appColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.tr,
                  style: context.texts.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                RichText(
                  text: TextSpan(
                    style: context.texts.headlineSmall?.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: 'home.welcome'.tr),
                      TextSpan(
                        text: username == 'common.guest'
                            ? 'common.guest'.tr
                            : username,
                        style: TextStyle(color: context.appColors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const SunIllustration(size: 68),
        ],
      ),
    );
  }
}
