import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/document_search_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../home/widgets/recent_uploads_widget.dart';
import '../home/widgets/search_bar_widget.dart';

/// Dedicated local search screen for documents.
class DocumentSearchView extends GetView<DocumentSearchController> {
  const DocumentSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('search.title'.tr),
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 720,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Obx(
                  () => SearchBarWidget(
                    controller: controller.searchFieldController,
                    focusNode: controller.searchFocusNode,
                    autofocus: true,
                    hintText: 'search.hint'.tr,
                    onChanged: controller.onSearch,
                    onSubmitted: controller.onSearch,
                    showClear: controller.hasQuery.value,
                    onClear: controller.clearSearch,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (!controller.hasQuery.value) {
                    return _SearchHint(
                      documentCount: controller.allDocuments.length,
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: RecentUploadsWidget(
                      documents: controller.searchResults.toList(),
                      isSearchMode: true,
                      searchQuery: controller.searchQuery.value,
                      onSeeAll: () {},
                      onItemTap: controller.openDocument,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.documentCount});

  final int documentCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 56,
              color: context.colors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'search.heading'.tr,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              documentCount == 0
                  ? 'search.emptyLibrary'.tr
                  : 'search.prompt'.tr,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
