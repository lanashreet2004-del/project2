import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/documents_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import 'widgets/document_item_tile.dart';

/// My Documents screen — UI only.
class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('documents.title'.tr),
        actions: [
          Obx(() {
            if (controller.documents.isEmpty) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: () => _confirmClearAll(context),
              child: Text(
                'documents.clearAll'.tr,
                style: TextStyle(color: context.appColors.onAppBar),
              ),
            );
          }),
        ],
      ),
      body: Obx(
        () => AsyncStateBuilder(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.loadDocuments,
          builder: (context) {
            final documents = controller.documents;

            if (documents.isEmpty) {
              return _EmptyDocumentsState(
                onScanTap: controller.scanNewDocument,
              );
            }

            return ResponsiveContainer(
              maxWidth: 800,
              child: RefreshIndicator(
                onRefresh: controller.loadDocuments,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = documents[index];
                    return DocumentItemTile(
                      item: item,
                      onTap: () => controller.openDocument(item),
                      onDelete: () => _confirmDelete(context, item.id),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('documents.deleteTitle'.tr),
        content: Text('documents.deleteBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common.delete'.tr,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteDocument(id);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('documents.clearTitle'.tr),
        content: Text('documents.clearBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'documents.clearAll'.tr,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.clearAll();
    }
  }
}

class _EmptyDocumentsState extends StatelessWidget {
  const _EmptyDocumentsState({required this.onScanTap});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.appColors.iconSoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.folder_open_outlined,
                size: 48,
                color: context.colors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'documents.emptyTitle'.tr,
              style: context.texts.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'documents.emptyBody'.tr,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: onScanTap,
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(
                  'documents.scanNew'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
