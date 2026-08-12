import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
        color: AppColors.welcomeCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome, '),
                      TextSpan(
                        text: username,
                        style: const TextStyle(color: AppColors.nameHighlight),
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
