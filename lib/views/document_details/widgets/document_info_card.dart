import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class DocumentInfoCard extends StatelessWidget {
  const DocumentInfoCard({
    super.key,
    required this.documentId,
    required this.savedDate,
    required this.confidence,
    required this.statusBadges,
  });

  final String documentId;
  final String savedDate;
  final double confidence;
  final List<String> statusBadges;

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.info'.tr,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'details.id'.tr,
              value: documentId,
              valueStyle: context.texts.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'details.savedDate'.tr, value: savedDate),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'details.confidence'.tr,
              value: '$confidencePercent%',
            ),
            const SizedBox(height: 16),
            Text(
              'details.status'.tr,
              style: context.texts.labelLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusBadges.map(_StatusBadge.new).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.statusKey);

  final String statusKey;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;

    switch (statusKey) {
      case 'details.badgeEdited':
        background = context.appColors.warning.withValues(alpha: 0.15);
        foreground = context.appColors.warning;
      case 'details.badgeExported':
        background = context.appColors.info.withValues(alpha: 0.15);
        foreground = context.appColors.info;
      default:
        background = context.appColors.success.withValues(alpha: 0.15);
        foreground = context.appColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Text(
        statusKey.tr,
        style: context.texts.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
