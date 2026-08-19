import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/word_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_library_file_tile.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../../models/word_file_model.dart';

/// Local library of exported Word files — UI only.
class WordFilesView extends GetView<WordFilesController> {
  const WordFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('wordFiles.title'.tr),
      ),
      body: Obx(
        () {
          final isLoading = controller.isLoading.value;
          final errorMessage = controller.errorMessage.value;
          final files = controller.wordFiles.toList(growable: false);
          return AsyncStateBuilder(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRetry: controller.loadWordFiles,
            builder: (context) {
              if (files.isEmpty) {
                return AppEmptyState(
                  icon: Icons.description_outlined,
                  title: 'wordFiles.emptyTitle'.tr,
                  body: 'wordFiles.emptyBody'.tr,
                  actionLabel: 'common.goHome'.tr,
                  actionIcon: Icons.home_outlined,
                  onAction: controller.goHome,
                );
              }

              return ResponsiveContainer(
                maxWidth: 800,
                child: RefreshIndicator(
                  onRefresh: controller.loadWordFiles,
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
                        icon: Icons.description_outlined,
                        iconColor: context.colors.primary,
                        iconBackground: context.appColors.iconSoft,
                        actionsTooltip: 'wordFiles.actions'.tr,
                        onOpen: () => _handleOpen(context, item),
                        onShare: () => controller.shareWord(item),
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

  Future<void> _handleOpen(BuildContext context, WordFileModel item) async {
    final exists = await controller.fileExists(item);
    if (!exists) {
      if (!context.mounted) return;
      await _showMissingFileDialog(context, item);
      return;
    }
    await controller.openWord(item);
  }

  Future<void> _showMissingFileDialog(
    BuildContext context,
    WordFileModel item,
  ) async {
    final remove = await Get.dialog<bool>(
      AlertDialog(
        title: Text('common.fileNotFound'.tr),
        content: Text('wordFiles.missingBody'.tr),
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

  Future<void> _confirmDelete(BuildContext context, WordFileModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('wordFiles.deleteTitle'.tr),
        content: Text(
          'wordFiles.deleteBody'.trParams({'name': item.fileName}),
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
      await controller.deleteWord(item.id);
    }
  }
}
