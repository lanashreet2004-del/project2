import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class JsonCodeBlock extends StatelessWidget {
  const JsonCodeBlock({
    super.key,
    required this.jsonText,
  });

  final String jsonText;

  @override
  Widget build(BuildContext context) {
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
              style: context.texts.bodyMedium?.copyWith(
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
                color: context.appColors.iconSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.data_object, color: context.colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'jsonPreview.headerTitle'.tr,
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'jsonPreview.headerSubtitle'.tr,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
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
