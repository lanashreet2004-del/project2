import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class ResultExtractedTextCard extends StatelessWidget {
  const ResultExtractedTextCard({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = text.isEmpty ? 'result.noText'.tr : text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'result.extractedText'.tr,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SelectableText(
                displayText,
                style: context.texts.bodyLarge?.copyWith(
                  height: 1.8,
                  letterSpacing: 0.2,
                  color: text.isEmpty
                      ? context.colors.onSurfaceVariant
                      : context.colors.onSurface,
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
