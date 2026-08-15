import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme_context.dart';
import '../../core/utils/document_image_path.dart';
import '../../core/widgets/document_image.dart';
import '../../core/widgets/wavy_app_bar.dart';

class DocumentImagePreviewView extends StatelessWidget {
  const DocumentImagePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String? ?? '';
    final hasImage = imagePath.isNotEmpty &&
        (DocumentImagePath.isNetworkUrl(imagePath) ||
            DocumentImagePath.isLocalFile(imagePath));

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('details.preview'.tr),
      ),
      body: Center(
        child: hasImage
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: DocumentImage(
                  imagePath: imagePath,
                  fit: BoxFit.contain,
                  placeholderIconSize: 64,
                ),
              )
            : Icon(
                Icons.image_not_supported_outlined,
                color: context.colors.onSurfaceVariant,
                size: 64,
              ),
      ),
    );
  }
}
