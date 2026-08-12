import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ResultExtractedTextCard extends StatelessWidget {
  const ResultExtractedTextCard({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = text.isEmpty ? 'No text extracted.' : text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extracted Text',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SelectableText(
                displayText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  letterSpacing: 0.2,
                  color: text.isEmpty
                      ? AppColors.textSecondary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
