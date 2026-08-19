import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/result_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/async_state_builder.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import '../document_details/widgets/document_actions_grid.dart';
import 'widgets/result_extracted_text_card.dart';
import 'widgets/result_image_preview.dart';
import 'widgets/result_metadata_row.dart';

/// OCR result screen — UI only.
class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('result.title'.tr),
      ),
      body: Obx(
        () => AsyncStateBuilder(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          onRetry: controller.loadResult,
          builder: (context) {
            final result = controller.result.value;

            if (result == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 56,
                        color: context.colors.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'result.noResultTitle'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'result.noResultBody'.tr,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
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
                      processedAt: result.processedAt,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ResultExtractedTextCard(
                        text: controller.result.value?.extractedText ?? '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: Obx(
                        () => FilledButton.icon(
                          onPressed: controller.isSaving.value ||
                                  controller.isExporting
                              ? null
                              : controller.saveDocument,
                          icon: controller.isSaving.value
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.colors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            controller.isSaving.value
                                ? 'common.saving'.tr
                                : 'result.saveDocument'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
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
                      child: Obx(
                        () => OutlinedButton.icon(
                          onPressed: controller.isSaving.value ||
                                  controller.isExporting
                              ? null
                              : controller.openTextEditor,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(
                            'result.editText'.tr,
                            style: const TextStyle(
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
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => DocumentActionsGrid(
                        titleKey: 'result.export',
                        actions: [
                          DocumentActionItem(
                            label: 'details.exportPdf'.tr,
                            icon: Icons.picture_as_pdf_outlined,
                            isLoading: controller.isExportingPdf.value,
                            isEnabled: !controller.isSaving.value &&
                                !controller.isExportingWord.value &&
                                !controller.isExportingExcel.value,
                            onTap: controller.exportPdf,
                          ),
                          DocumentActionItem(
                            label: 'details.exportWord'.tr,
                            icon: Icons.description_outlined,
                            isLoading: controller.isExportingWord.value,
                            isEnabled: !controller.isSaving.value &&
                                !controller.isExportingPdf.value &&
                                !controller.isExportingExcel.value,
                            onTap: controller.exportWord,
                          ),
                          DocumentActionItem(
                            label: 'details.exportExcel'.tr,
                            icon: Icons.table_chart_outlined,
                            isLoading: controller.isExportingExcel.value,
                            isEnabled: !controller.isSaving.value &&
                                !controller.isExportingPdf.value &&
                                !controller.isExportingWord.value,
                            onTap: controller.exportExcel,
                          ),
                        ],
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
