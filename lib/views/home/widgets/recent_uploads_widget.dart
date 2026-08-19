import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
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
        AppSectionHeader(
          title: isSearchMode
              ? 'home.searchResults'.tr
              : 'home.recentDocuments'.tr,
          actionLabel: isSearchMode ? null : 'home.seeAll'.tr,
          onAction: isSearchMode ? null : onSeeAll,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (documents.isEmpty)
          AppEmptyState(
            icon: isSearchMode
                ? Icons.search_off_outlined
                : Icons.folder_open_outlined,
            title: isSearchMode
                ? 'home.noResultsTitle'.tr
                : 'home.emptyTitle'.tr,
            body: isSearchMode
                ? 'home.noResultsBody'.trParams({'query': searchQuery})
                : 'home.emptyBody'.tr,
          )
        else
          ...documents.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
