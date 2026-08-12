import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/upload_controller.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../routes/app_routes.dart';

/// Upload screen — shows edited image ready for future API upload.
class UploadView extends GetView<UploadController> {
  const UploadView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Obx(
        () => AsyncStateBuilder(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.upload,
          loadingMessage: 'Uploading...',
          builder: (context) {
            final filePath =
                controller.editedImagePath.value ?? controller.selectedFilePath.value;

            return ResponsiveContainer(
              maxWidth: 600,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ImagePreview(filePath: filePath),
                    const SizedBox(height: 20),
                    Text(
                      filePath != null
                          ? _fileName(filePath)
                          : 'No image selected',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: filePath != null
                          ? () => Get.toNamed(AppRoutes.processing)
                          : null,
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Process OCR'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

String _fileName(String path) {
  final separator = Platform.pathSeparator;
  final index = path.lastIndexOf(separator);
  return index == -1 ? path : path.substring(index + 1);
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.filePath});

  final String? filePath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (filePath == null || !File(filePath!).existsSync()) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No edited image available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(filePath!),
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
