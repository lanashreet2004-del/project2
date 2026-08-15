import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme_context.dart';
import '../utils/document_image_path.dart';

/// Renders a document thumbnail/preview from a local path or remote URL.
class DocumentImage extends StatelessWidget {
  const DocumentImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 28,
  });

  final String imagePath;
  final BoxFit fit;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    final path = imagePath.trim();
    if (path.isEmpty) return _placeholder(context);

    if (DocumentImagePath.isNetworkUrl(path)) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context, broken: true),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: context.appColors.iconSoft,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }

    try {
      final file = File(path);
      if (!file.existsSync()) return _placeholder(context);
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(context, broken: true),
      );
    } catch (_) {
      return _placeholder(context);
    }
  }

  Widget _placeholder(BuildContext context, {bool broken = false}) {
    return ColoredBox(
      color: context.appColors.iconSoft,
      child: Center(
        child: Icon(
          broken ? Icons.broken_image_outlined : Icons.image_outlined,
          size: placeholderIconSize,
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
