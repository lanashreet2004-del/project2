import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/text_editor_controller.dart';
import '../../core/theme/app_colors.dart';

/// OCR text editing screen — UI only.
class TextEditorView extends GetView<TextEditorController> {
  const TextEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Edit Text'),
        centerTitle: true,
        leading: TextButton(
          onPressed: controller.onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: controller.onDone,
            child: Text(
              'Done',
              style: TextStyle(
                color: theme.colorScheme.primary,
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
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: controller.textController,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.multiline,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل النص المستخرج...',
                      hintTextDirection: TextDirection.rtl,
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${controller.characterCount.value} characters',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
