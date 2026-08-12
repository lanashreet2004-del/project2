import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/result_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/result_extracted_text_card.dart';
import 'widgets/result_image_preview.dart';
import 'widgets/result_metadata_row.dart';

/// OCR result screen — UI only.
class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Result'),
        centerTitle: true,
      ),
      body: Obx(
        () => AsyncStateBuilder(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.loadResult,
          builder: (context) {
            final result = controller.result.value;

            if (result == null) {
              return const Center(child: Text('No result available'));
            }

            return ResponsiveContainer(
              maxWidth: 800,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ResultImagePreview(imagePath: result.imagePath),
                    const SizedBox(height: 16),
                    ResultMetadataRow(
                      confidence: result.confidence,
                      processedAt: result.processedAt,
                    ),
                    const SizedBox(height: 16),
                    ResultExtractedTextCard(text: result.extractedText),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: Obx(
                        () => FilledButton.icon(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveDocument,
                          icon: controller.isSaving.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            controller.isSaving.value
                                ? 'Saving...'
                                : 'Save Document',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: controller.openTextEditor,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(
                          'Edit Text',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
