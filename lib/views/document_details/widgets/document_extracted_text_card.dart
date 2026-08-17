import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class DocumentExtractedTextCard extends StatelessWidget {
  const DocumentExtractedTextCard({
    super.key,
    required this.text,
    this.onEdit,
  });

  final String text;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final displayText = text.isEmpty ? 'details.noText'.tr : text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'details.extractedText'.tr,
                    style: context.texts.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    key: const Key('extracted_text_edit'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'details.editText'.tr,
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: context.colors.primary,
                    ),
                  ),
              ],
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
