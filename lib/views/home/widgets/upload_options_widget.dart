import 'package:flutter/material.dart';

import 'camera_card_widget.dart';
import 'gallery_card_widget.dart';
import 'my_documents_card_widget.dart';

/// Upload options section with gallery, camera, and documents cards.
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
        const Text(
          'Ready To Share Your Document With Us ?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: GalleryCardWidget(onTap: onGalleryTap)),
            const SizedBox(width: 14),
            Expanded(child: CameraCardWidget(onTap: onCameraTap)),
            const SizedBox(width: 14),
            Expanded(child: MyDocumentsCardWidget(onTap: onDocumentsTap)),
          ],
        ),
      ],
    );
  }
}
