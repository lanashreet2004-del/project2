import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/text_editor_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/wavy_app_bar.dart';

/// OCR text editing screen — UI only.
class TextEditorView extends GetView<TextEditorController> {
  const TextEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: !controller.hasChanges.value && !controller.isSaving.value,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await controller.onCancel();
        },
        child: Scaffold(
          backgroundColor: context.colors.surfaceContainerLowest,
          appBar: WavyAppBar(
            title: Text('textEditor.title'.tr),
            leading: TextButton(
              onPressed: controller.isSaving.value ? null : controller.onCancel,
              child: Text(
                'textEditor.cancel'.tr,
                style: TextStyle(color: context.appColors.onAppBar),
              ),
            ),
            leadingWidth: 80,
            actions: [
              TextButton(
                onPressed:
                    controller.isSaving.value ? null : controller.onDone,
                child: controller.isSaving.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.appColors.onAppBar,
                          ),
                        ),
                      )
                    : Text(
                        'textEditor.done'.tr,
                        style: TextStyle(
                          color: context.appColors.onAppBar,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (controller.hasChanges.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'textEditor.unsavedTitle'.tr,
                        style: context.texts.labelMedium?.copyWith(
                          color: context.appColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: controller.textController,
                        enabled: !controller.isSaving.value,
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        keyboardType: TextInputType.multiline,
                        style: context.texts.bodyLarge?.copyWith(
                          height: 1.8,
                          letterSpacing: 0.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'textEditor.hint'.tr,
                          hintTextDirection: TextDirection.rtl,
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: context.colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'common.characters'.trParams({
                        'count': '${controller.characterCount.value}',
                      }),
                      style: context.texts.labelMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
