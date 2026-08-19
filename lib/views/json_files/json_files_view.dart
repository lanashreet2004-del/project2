import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/json_files_controller.dart';
import '../../core/localization/display_helpers.dart';
import '../../core/theme/app_theme_context.dart';
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
                return _EmptyJsonFilesState(onHomeTap: controller.goHome);
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
                    return _JsonFileTile(
                      item: item,
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

class _JsonFileTile extends StatelessWidget {
  const _JsonFileTile({
    required this.item,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final JsonFileModel item;
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
                  color: context.appColors.iconSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.data_object_outlined,
                  color: context.colors.primary,
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
              PopupMenuButton<_JsonAction>(
                tooltip: 'jsonFiles.actions'.tr,
                onSelected: (action) {
                  switch (action) {
                    case _JsonAction.open:
                      onOpen();
                    case _JsonAction.share:
                      onShare();
                    case _JsonAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _JsonAction.open,
                    child: Text('common.open'.tr),
                  ),
                  PopupMenuItem(
                    value: _JsonAction.share,
                    child: Text('common.share'.tr),
                  ),
                  PopupMenuItem(
                    value: _JsonAction.delete,
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

enum _JsonAction { open, share, delete }

class _EmptyJsonFilesState extends StatelessWidget {
  const _EmptyJsonFilesState({required this.onHomeTap});

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
              Icons.data_object_outlined,
              size: 64,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'jsonFiles.emptyTitle'.tr,
              textAlign: TextAlign.center,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'jsonFiles.emptyBody'.tr,
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
