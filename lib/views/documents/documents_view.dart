import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/documents_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/app_empty_state.dart';
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
              return AppEmptyState(
                icon: Icons.folder_open_outlined,
                title: 'documents.emptyTitle'.tr,
                body: 'documents.emptyBody'.tr,
                actionLabel: 'documents.scanNew'.tr,
                actionIcon: Icons.document_scanner_outlined,
                onAction: controller.scanNewDocument,
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
