import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_context.dart';
import '../../../models/json_export_validation_result.dart';

class JsonValidationCard extends StatelessWidget {
  const JsonValidationCard({
    super.key,
    required this.validation,
  });

  final JsonExportValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final isValid = validation.isValid;
    final statusColor =
        isValid ? context.appColors.success : context.appColors.warning;

    return Card(
      color: isValid
          ? context.appColors.success.withValues(alpha: 0.08)
          : context.appColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isValid ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              color: statusColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    validation.statusTitle,
                    style: context.texts.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    validation.statusMessage,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      height: 1.5,
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
