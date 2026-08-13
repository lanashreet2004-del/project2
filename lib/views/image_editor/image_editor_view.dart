import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/image_editor_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/wavy_app_bar.dart';
import 'widgets/image_editor_preview.dart';
import 'widgets/image_editor_toolbar.dart';

/// Image editing screen — UI only.
class ImageEditorView extends GetView<ImageEditorController> {
  const ImageEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('editor.title'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.workingImagePath.value == null) {
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
                    onPressed:
                        controller.isLoading.value ? null : controller.onDone,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colors.onPrimary,
                            ),
                          )
                        : Text(
                            'editor.done'.tr,
                            style: const TextStyle(
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
