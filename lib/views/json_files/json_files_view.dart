import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/json_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_library_file_tile.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../../models/json_file_model.dart';

/// Local library of exported JSON files — UI only.
class JsonFilesView extends GetView<JsonFilesController> {
  const JsonFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('jsonFiles.title'.tr),
      ),
      body: Obx(
        () {
          final isLoading = controller.isLoading.value;
          final errorMessage = controller.errorMessage.value;
          final files = controller.jsonFiles.toList(growable: false);
          return AsyncStateBuilder(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRetry: controller.loadJsonFiles,
            builder: (context) {
              if (files.isEmpty) {
                return AppEmptyState(
                  icon: Icons.data_object_outlined,
                  title: 'jsonFiles.emptyTitle'.tr,
                  body: 'jsonFiles.emptyBody'.tr,
                  actionLabel: 'common.goHome'.tr,
                  actionIcon: Icons.home_outlined,
                  onAction: controller.goHome,
                );
              }

              return ResponsiveContainer(
                maxWidth: 800,
                child: RefreshIndicator(
                  onRefresh: controller.loadJsonFiles,
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
                        icon: Icons.data_object_outlined,
                        iconColor: context.appColors.accent,
                        iconBackground: context.appColors.accentSoft,
                        actionsTooltip: 'jsonFiles.actions'.tr,
                        onOpen: () => _handleOpen(context, item),
                        onShare: () => controller.shareJson(item),
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

  Future<void> _handleOpen(BuildContext context, JsonFileModel item) async {
    final exists = await controller.fileExists(item);
    if (!exists) {
      if (!context.mounted) return;
      await _showMissingFileDialog(context, item);
      return;
    }
    await controller.openJson(item);
  }

  Future<void> _showMissingFileDialog(
    BuildContext context,
    JsonFileModel item,
  ) async {
    final remove = await Get.dialog<bool>(
      AlertDialog(
        title: Text('common.fileNotFound'.tr),
        content: Text('jsonFiles.missingBody'.tr),
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

  Future<void> _confirmDelete(BuildContext context, JsonFileModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('jsonFiles.deleteTitle'.tr),
        content: Text(
          'jsonFiles.deleteBody'.trParams({'name': item.fileName}),
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
      await controller.deleteJson(item.id);
    }
  }
}
