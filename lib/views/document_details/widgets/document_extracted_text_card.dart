import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DocumentExtractedTextCard extends StatelessWidget {
  const DocumentExtractedTextCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = text.isEmpty ? 'No extracted text available.' : text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extracted Text',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SelectableText(
                    displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.85,
                      letterSpacing: 0.2,
                      color: text.isEmpty
                          ? AppColors.textSecondary
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
