import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class JsonCodeBlock extends StatelessWidget {
  const JsonCodeBlock({
    super.key,
    required this.jsonText,
  });

  final String jsonText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF1E1E2E),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Courier New', 'monospace'],
                color: const Color(0xFFCDD6F4),
                height: 1.55,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JsonPreviewHeader extends StatelessWidget {
  const JsonPreviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconBgPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.data_object, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Payload Preview',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and validate JSON before saving or sharing.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
