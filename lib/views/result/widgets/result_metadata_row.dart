import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class ResultMetadataRow extends StatelessWidget {
  const ResultMetadataRow({
    super.key,
    required this.confidence,
    required this.processedAt,
  });

  final double confidence;
  final DateTime processedAt;

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (confidence * 100).clamp(0, 100).toStringAsFixed(0);
    final dateLabel = _formatDateTime(processedAt);

    return Row(
      children: [
        Expanded(
          child: _MetaChip(
            icon: Icons.verified_outlined,
            label: 'result.confidence'.tr,
            value: '$confidencePercent%',
            color: _confidenceColor(context, confidence),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetaChip(
            icon: Icons.schedule_outlined,
            label: 'result.processed'.tr,
            value: dateLabel,
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }

  Color _confidenceColor(BuildContext context, double value) {
    if (value >= 0.8) return context.appColors.success;
    if (value >= 0.5) return context.appColors.warning;
    return context.colors.error;
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.texts.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
