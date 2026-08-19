import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme_context.dart';

enum _LibraryFileAction { open, share, delete }

/// Shared generated-file row used by PDF / Word / Excel / JSON libraries.
class AppLibraryFileTile extends StatelessWidget {
  const AppLibraryFileTile({
    super.key,
    required this.fileName,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.actionsTooltip,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final String fileName;
  final String subtitle;
  final String meta;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String actionsTooltip;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  static String formatSize(int bytes) {
    if (bytes <= 0) return '—';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    }
    if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: AppSpacing.cardCompact,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.labelSmall?.copyWith(
                        color: context.appColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_LibraryFileAction>(
                tooltip: actionsTooltip,
                onSelected: (action) {
                  switch (action) {
                    case _LibraryFileAction.open:
                      onOpen();
                    case _LibraryFileAction.share:
                      onShare();
                    case _LibraryFileAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _LibraryFileAction.open,
                    child: Text('common.open'.tr),
                  ),
                  PopupMenuItem(
                    value: _LibraryFileAction.share,
                    child: Text('common.share'.tr),
                  ),
                  PopupMenuItem(
                    value: _LibraryFileAction.delete,
                    child: Text('common.delete'.tr),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
