import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_context.dart';
import 'camera_card_widget.dart';
import 'gallery_card_widget.dart';
import 'my_documents_card_widget.dart';

/// Upload options: Gallery + Camera primary row, My Documents secondary below.
class UploadOptionsWidget extends StatelessWidget {
  const UploadOptionsWidget({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onDocumentsTap,
  });

  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onDocumentsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'home.readyTitle'.tr,
          style: context.texts.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: GalleryCardWidget(onTap: onGalleryTap)),
            const SizedBox(width: 14),
            Expanded(child: CameraCardWidget(onTap: onCameraTap)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        MyDocumentsCardWidget(onTap: onDocumentsTap),
      ],
    );
  }
}
