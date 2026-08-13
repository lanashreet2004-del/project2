import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
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
        () => AsyncStateBuilder(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.loadPdfFiles,
          builder: (context) {
            final files = controller.pdfFiles;

            if (files.isEmpty) {
              return _EmptyPdfFilesState(onHomeTap: controller.goHome);
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
                    return _PdfFileTile(
                      item: item,
                      onOpen: () => _handleOpen(context, item),
                      onShare: () => controller.sharePdf(item),
                      onDelete: () => _confirmDelete(context, item),
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

class _PdfFileTile extends StatelessWidget {
  const _PdfFileTile({
    required this.item,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final PdfFileModel item;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatExportDate(item.exportedAt);
    final sizeLabel = _formatFileSize(item.fileSizeBytes);
    final subtitle = item.documentTitle.trim().isEmpty
        ? item.fileName
        : displayDocumentTitle(item.documentTitle);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.errorContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: context.colors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dateLabel • $sizeLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_PdfAction>(
                tooltip: 'pdfFiles.actions'.tr,
                onSelected: (action) {
                  switch (action) {
                    case _PdfAction.open:
                      onOpen();
                    case _PdfAction.share:
                      onShare();
                    case _PdfAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _PdfAction.open,
                    child: Text('common.open'.tr),
                  ),
                  PopupMenuItem(
                    value: _PdfAction.share,
                    child: Text('common.share'.tr),
                  ),
                  PopupMenuItem(
                    value: _PdfAction.delete,
                    child: Text('common.delete'.tr),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatExportDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  String _formatFileSize(int bytes) {
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
}

enum _PdfAction { open, share, delete }

class _EmptyPdfFilesState extends StatelessWidget {
  const _EmptyPdfFilesState({required this.onHomeTap});

  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'pdfFiles.emptyTitle'.tr,
              textAlign: TextAlign.center,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'pdfFiles.emptyBody'.tr,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onHomeTap,
              icon: const Icon(Icons.home_outlined),
              label: Text('common.goHome'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
