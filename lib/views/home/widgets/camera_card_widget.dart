import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'upload_option_card.dart';

/// Camera upload option card.
class CameraCardWidget extends StatelessWidget {
  const CameraCardWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UploadOptionCard(
      onTap: onTap,
      icon: Icons.camera_alt_outlined,
      title: 'home.camera'.tr,
      subtitle: 'home.cameraSubtitle'.tr,
    );
  }
}
