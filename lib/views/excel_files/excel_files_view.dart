import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/excel_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_library_file_tile.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../../models/excel_file_model.dart';

/// Local library of exported Excel files — UI only.
class ExcelFilesView extends GetView<ExcelFilesController> {
  const ExcelFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('excelFiles.title'.tr),
      ),
      body: Obx(
        () {
          final isLoading = controller.isLoading.value;
          final errorMessage = controller.errorMessage.value;
          final files = controller.excelFiles.toList(growable: false);
          return AsyncStateBuilder(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRetry: controller.loadExcelFiles,
            builder: (context) {
              if (files.isEmpty) {
                return AppEmptyState(
                  icon: Icons.table_chart_outlined,
                  title: 'excelFiles.emptyTitle'.tr,
                  body: 'excelFiles.emptyBody'.tr,
                  actionLabel: 'common.goHome'.tr,
                  actionIcon: Icons.home_outlined,
                  onAction: controller.goHome,
                );
              }

              return ResponsiveContainer(
                maxWidth: 800,
                child: RefreshIndicator(
                  onRefresh: controller.loadExcelFiles,
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
                        icon: Icons.table_chart_outlined,
                        iconColor: context.appColors.success,
                        iconBackground: context.appColors.iconSoft,
                        actionsTooltip: 'excelFiles.actions'.tr,
                        onOpen: () => _handleOpen(context, item),
                        onShare: () => controller.shareExcel(item),
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

  Future<void> _handleOpen(BuildContext context, ExcelFileModel item) async {
    final exists = await controller.fileExists(item);
    if (!exists) {
      if (!context.mounted) return;
      await _showMissingFileDialog(context, item);
      return;
    }
    await controller.openExcel(item);
  }

  Future<void> _showMissingFileDialog(
    BuildContext context,
    ExcelFileModel item,
  ) async {
    final remove = await Get.dialog<bool>(
      AlertDialog(
        title: Text('common.fileNotFound'.tr),
        content: Text('excelFiles.missingBody'.tr),
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

  Future<void> _confirmDelete(BuildContext context, ExcelFileModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('excelFiles.deleteTitle'.tr),
        content: Text(
          'excelFiles.deleteBody'.trParams({'name': item.fileName}),
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
      await controller.deleteExcel(item.id);
    }
  }
}
