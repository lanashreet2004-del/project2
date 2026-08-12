import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/json_export_validation_result.dart';

class JsonValidationCard extends StatelessWidget {
  const JsonValidationCard({
    super.key,
    required this.validation,
  });

  final JsonExportValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = validation.isValid;

    return Card(
      color: isValid
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.warning.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isValid ? Icons.check_circle_outline : Icons.warning_amber_outlined,
              color: isValid ? AppColors.success : AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    validation.statusTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isValid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    validation.statusMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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
