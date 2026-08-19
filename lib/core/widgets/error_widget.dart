import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme_context.dart';

/// Reusable error state widget with optional retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.1),
                  borderRadius: AppRadii.lgAll,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: context.colors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: context.texts.bodyLarge?.copyWith(height: 1.45),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('errors.retry'.tr),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
