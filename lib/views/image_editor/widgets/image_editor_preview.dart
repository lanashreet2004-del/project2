import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Large image preview with live brightness filter.
class ImageEditorPreview extends StatelessWidget {
  const ImageEditorPreview({
    super.key,
    required this.imagePath,
    required this.brightnessMatrix,
    required this.brightnessValue,
  });

  final String? imagePath;
  final List<double> brightnessMatrix;
  final double brightnessValue;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || !File(imagePath!).existsSync()) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text('editor.noImage'.tr)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(brightnessMatrix),
          child: Image.file(
            File(imagePath!),
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
