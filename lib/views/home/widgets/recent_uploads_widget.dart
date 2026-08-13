import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';
import '../../../models/history_model.dart';
import 'recent_upload_item.dart';

/// Recent documents section with header, list, and empty state.
class RecentUploadsWidget extends StatelessWidget {
  const RecentUploadsWidget({
    super.key,
    required this.documents,
    required this.onSeeAll,
    required this.onItemTap,
    this.isSearchMode = false,
    this.searchQuery = '',
  });

  final List<HistoryModel> documents;
  final VoidCallback onSeeAll;
  final ValueChanged<HistoryModel> onItemTap;
  final bool isSearchMode;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSearchMode ? 'home.searchResults'.tr : 'home.recentDocuments'.tr,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
            if (!isSearchMode)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'home.seeAll'.tr,
                  style: context.texts.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (documents.isEmpty)
          _EmptyState(
            isSearchMode: isSearchMode,
            searchQuery: searchQuery,
          )
        else
          ...documents.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RecentDocumentItem(
                document: document,
                onTap: () => onItemTap(document),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isSearchMode,
    required this.searchQuery,
  });

  final bool isSearchMode;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(
            isSearchMode ? Icons.search_off_outlined : Icons.folder_open_outlined,
            size: 40,
            color: context.colors.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 12),
          Text(
            isSearchMode ? 'home.noResultsTitle'.tr : 'home.emptyTitle'.tr,
            style: context.texts.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearchMode
                ? 'home.noResultsBody'.trParams({'query': searchQuery})
                : 'home.emptyBody'.tr,
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
