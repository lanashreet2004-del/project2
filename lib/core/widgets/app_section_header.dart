import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme_context.dart';

/// Section title with optional trailing action.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
