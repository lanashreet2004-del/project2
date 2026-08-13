import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/wavy_app_bar.dart';

class DocumentImagePreviewView extends StatelessWidget {
  const DocumentImagePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String? ?? '';

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('details.preview'.tr),
      ),
      body: Center(
        child: imagePath.isNotEmpty && File(imagePath).existsSync()
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: context.colors.onSurfaceVariant,
                    size: 64,
                  ),
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
