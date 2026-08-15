import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme_context.dart';
import '../../../core/widgets/document_image.dart';

class DocumentDetailsPreview extends StatelessWidget {
  const DocumentDetailsPreview({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.appColors.cardBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DocumentImage(
                  imagePath: imagePath,
                  placeholderIconSize: 56,
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.zoom_out_map,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'details.tapToPreview'.tr,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
