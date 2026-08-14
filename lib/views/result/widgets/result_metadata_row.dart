import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class ResultMetadataRow extends StatelessWidget {
  const ResultMetadataRow({
    super.key,
    required this.processedAt,
  });

  final DateTime processedAt;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDateTime(processedAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.schedule_outlined, size: 16, color: context.colors.primary),
            const SizedBox(width: 6),
            Text(
              'result.processed'.tr,
              style: context.texts.labelMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              dateLabel,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}
