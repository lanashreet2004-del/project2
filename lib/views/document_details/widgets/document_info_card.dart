import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
    final theme = Theme.of(context);
    final confidencePercent =
        (confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Document ID',
              value: documentId,
              valueStyle: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Saved Date', value: savedDate),
            const SizedBox(height: 12),
            _InfoRow(label: 'Confidence Score', value: '$confidencePercent%'),
            const SizedBox(height: 16),
            Text(
              'Document Status',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background;
    Color foreground;

    switch (status) {
      case 'Edited':
        background = AppColors.warning.withValues(alpha: 0.15);
        foreground = AppColors.warning;
      case 'Exported':
        background = AppColors.info.withValues(alpha: 0.15);
        foreground = AppColors.info;
      default:
        background = AppColors.success.withValues(alpha: 0.15);
        foreground = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
