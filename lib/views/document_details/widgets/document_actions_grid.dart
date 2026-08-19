import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class DocumentActionItem {
  const DocumentActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;
  final bool isEnabled;
}

class DocumentActionsGrid extends StatelessWidget {
  const DocumentActionsGrid({
    super.key,
    required this.actions,
    this.titleKey = 'details.quickActions',
  });

  final List<DocumentActionItem> actions;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr,
          style: context.texts.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: actions.map((action) => _ActionTile(action: action)).toList(),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final DocumentActionItem action;

  @override
  Widget build(BuildContext context) {
    final enabled = action.isEnabled && !action.isLoading;
    final color =
        action.isDestructive ? context.colors.error : context.colors.primary;
    final bgColor = action.isDestructive
        ? context.colors.error.withValues(alpha: 0.08)
        : context.appColors.iconSoft;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? action.onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: action.isDestructive
                    ? context.colors.error.withValues(alpha: 0.25)
                    : context.appColors.cardBorder,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: action.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: color,
                          ),
                        )
                      : Icon(action.icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  action.isLoading ? 'common.exporting'.tr : action.label,
                  style: context.texts.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: action.isDestructive
                        ? context.colors.error
                        : context.colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
