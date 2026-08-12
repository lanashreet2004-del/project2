import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class JsonStatsChips extends StatelessWidget {
  const JsonStatsChips({
    super.key,
    required this.characterCount,
    required this.wordCount,
    required this.lineCount,
    required this.confidence,
  });

  final int characterCount;
  final int wordCount;
  final int lineCount;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: 'Characters', value: characterCount.toString()),
        _StatChip(label: 'Words', value: wordCount.toString()),
        _StatChip(label: 'Lines', value: lineCount.toString()),
        _StatChip(label: 'Confidence', value: '$confidencePercent%'),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.iconBgPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
          ),
        ],
      ),
    );
  }
}
