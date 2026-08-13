import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'upload_option_card.dart';

/// Gallery upload option card.
class GalleryCardWidget extends StatelessWidget {
  const GalleryCardWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UploadOptionCard(
      onTap: onTap,
      icon: Icons.image_outlined,
      title: 'home.gallery'.tr,
      subtitle: 'home.gallerySubtitle'.tr,
    );
  }
}
