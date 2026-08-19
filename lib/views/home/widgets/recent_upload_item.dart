import 'package:flutter/material.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/localization/display_helpers.dart';
import '../../../core/theme/app_theme_context.dart';
import '../../../core/widgets/document_image.dart';
import '../../../models/history_model.dart';

/// Single recent document list item for Home.
class RecentDocumentItem extends StatelessWidget {
  const RecentDocumentItem({
    super.key,
    required this.document,
    required this.onTap,
  });

  final HistoryModel document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = displayDocumentTitle(HomeController.documentTitle(document));
    final subtitle = HomeController.relativeTime(document.createdAt);

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: DocumentImage(imagePath: document.imagePath),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: context.texts.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
