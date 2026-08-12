import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentImagePreviewView extends StatelessWidget {
  const DocumentImagePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Document Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: imagePath.isNotEmpty && File(imagePath).existsSync()
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              )
            : const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white54,
                size: 64,
              ),
      ),
    );
  }
}
