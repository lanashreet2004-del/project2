import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme_context.dart';

class ResultImagePreview extends StatelessWidget {
  const ResultImagePreview({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return Card(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: context.colors.outline,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.appColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
