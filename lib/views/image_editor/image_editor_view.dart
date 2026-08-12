import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/image_editor_controller.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/image_editor_preview.dart';
import 'widgets/image_editor_toolbar.dart';

/// Image editing screen — UI only.
class ImageEditorView extends GetView<ImageEditorController> {
  const ImageEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Edit Image'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.workingImagePath.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ImageEditorPreview(
                  imagePath: controller.workingImagePath.value,
                  brightnessMatrix: controller.brightnessColorMatrix,
                  brightnessValue: controller.brightness.value,
                ),
              ),
            ),
            ImageEditorToolbar(
              brightness: controller.brightness.value,
              minBrightness: ImageEditorController.minBrightness,
              maxBrightness: ImageEditorController.maxBrightness,
              onCrop: controller.showCropOptions,
              onRotateLeft: controller.rotateLeft,
              onRotateRight: controller.rotateRight,
              onRetake: controller.retakePhoto,
              onBrightnessChanged: controller.setBrightness,
              isBusy: controller.isLoading.value,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.onDone,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
