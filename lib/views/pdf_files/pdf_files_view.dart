import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_library_file_tile.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../../models/pdf_file_model.dart';

/// Local library of exported PDF files — UI only.
class PdfFilesView extends GetView<PdfFilesController> {
  const PdfFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('pdfFiles.title'.tr),
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () {
          final isLoading = controller.isLoading.value;
          final errorMessage = controller.errorMessage.value;
          final files = controller.pdfFiles.toList(growable: false);
          return AsyncStateBuilder(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRetry: controller.loadPdfFiles,
            builder: (context) {
              if (files.isEmpty) {
                return AppEmptyState(
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'pdfFiles.emptyTitle'.tr,
                  body: 'pdfFiles.emptyBody'.tr,
                  actionLabel: 'common.goHome'.tr,
                  actionIcon: Icons.home_outlined,
                  onAction: controller.goHome,
                );
              }

              return ResponsiveContainer(
                maxWidth: 800,
                child: RefreshIndicator(
                  onRefresh: controller.loadPdfFiles,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = files[index];
                      return AppLibraryFileTile(
                        fileName: item.fileName,
                        subtitle: item.documentTitle.trim().isEmpty
                            ? item.fileName
                            : displayDocumentTitle(item.documentTitle),
                        meta:
                            '${AppLibraryFileTile.formatDate(item.exportedAt)} • ${AppLibraryFileTile.formatSize(item.fileSizeBytes)}',
                        icon: Icons.picture_as_pdf_outlined,
                        iconColor: context.colors.error,
                        iconBackground: context.colors.errorContainer
                            .withValues(alpha: 0.55),
                        actionsTooltip: 'pdfFiles.actions'.tr,
                        onOpen: () => _handleOpen(context, item),
                        onShare: () => controller.sharePdf(item),
                        onDelete: () => _confirmDelete(context, item),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleOpen(BuildContext context, PdfFileModel item) async {
    final exists = await controller.fileExists(item);
    if (!exists) {
      if (!context.mounted) return;
      await _showMissingFileDialog(context, item);
      return;
    }
    await controller.openPdf(item);
  }

  Future<void> _showMissingFileDialog(
    BuildContext context,
    PdfFileModel item,
  ) async {
    final remove = await Get.dialog<bool>(
      AlertDialog(
        title: Text('common.fileNotFound'.tr),
        content: Text('pdfFiles.missingBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.keep'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common.remove'.tr,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (remove == true) {
      await controller.removeStaleEntry(item.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, PdfFileModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('pdfFiles.deleteTitle'.tr),
        content: Text(
          'pdfFiles.deleteBody'.trParams({'name': item.fileName}),
        ),
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
      await controller.deletePdf(item.id);
    }
  }
}
