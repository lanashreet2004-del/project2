import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';

class JsonStatsChips extends StatelessWidget {
  const JsonStatsChips({
    super.key,
    required this.characterCount,
    required this.wordCount,
    required this.lineCount,
  });

  final int characterCount;
  final int wordCount;
  final int lineCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          label: 'details.characters'.tr,
          value: characterCount.toString(),
        ),
        _StatChip(label: 'details.words'.tr, value: wordCount.toString()),
        _StatChip(label: 'details.lines'.tr, value: lineCount.toString()),
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
        color: context.appColors.iconSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: context.texts.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.texts.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
