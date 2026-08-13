import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: context.appColors.brandSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
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
                const SizedBox(height: 6),
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
          const SizedBox(width: 8),
          const SunIllustration(size: 72),
        ],
      ),
    );
  }
}
