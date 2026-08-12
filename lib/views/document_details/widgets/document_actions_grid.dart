import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DocumentActionItem {
  const DocumentActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

class DocumentActionsGrid extends StatelessWidget {
  const DocumentActionsGrid({super.key, required this.actions});

  final List<DocumentActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    final theme = Theme.of(context);
    final color = action.isDestructive ? AppColors.error : AppColors.accent;
    final bgColor = action.isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.iconBgPurple;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: action.isDestructive
                  ? AppColors.error.withValues(alpha: 0.25)
                  : AppColors.cardBorder,
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
                child: Icon(action.icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: action.isDestructive ? AppColors.error : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
