import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class DocumentExtractedTextCard extends StatelessWidget {
  const DocumentExtractedTextCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final displayText = text.isEmpty ? 'details.noText'.tr : text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.extractedText'.tr,
              style: context.texts.titleMedium?.copyWith(
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
                    style: context.texts.bodyLarge?.copyWith(
                      height: 1.85,
                      letterSpacing: 0.2,
                      color: text.isEmpty
                          ? context.colors.onSurfaceVariant
                          : context.colors.onSurface,
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
