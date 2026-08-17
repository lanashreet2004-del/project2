import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/document_details_controller.dart';
import '../../core/theme/app_theme_context.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/wavy_app_bar.dart';
import 'widgets/document_actions_grid.dart';
import 'widgets/document_details_preview.dart';
import 'widgets/document_extracted_text_card.dart';
import 'widgets/document_statistics_section.dart';

/// Document details screen — UI only.
class DocumentDetailsView extends GetView<DocumentDetailsController> {
  const DocumentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLowest,
      appBar: WavyAppBar(
        title: Text('details.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline,color: Colors.red),
            tooltip: 'common.delete'.tr,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Obx(() {
        final document = controller.document.value;
        if (document == null) {
          return Center(child: Text('details.notFound'.tr));
        }

        final exporting = controller.isExportingPdf.value ||
            controller.isExportingWord.value ||
            controller.isExportingExcel.value;

        return ResponsiveContainer(
          maxWidth: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DocumentDetailsPreview(
                  imagePath: document.imagePath,
                  onTap: controller.openFullScreenPreview,
                ),
                const SizedBox(height: 16),
                DocumentExtractedTextCard(
                  text: document.extractedText,
                  onEdit: controller.openTextEditor,
                ),
                const SizedBox(height: 20),
                DocumentActionsGrid(
                  actions: [
                    DocumentActionItem(
                      label: 'details.exportExcel'.tr,
                      icon: Icons.table_chart_outlined,
                      isLoading: controller.isExportingExcel.value,
                      isEnabled: !controller.isExportingPdf.value &&
                          !controller.isExportingWord.value,
                      onTap: controller.exportExcel,
                    ),
                    DocumentActionItem(
                      label: 'details.exportJson'.tr,
                      icon: Icons.code,
                      isEnabled: !exporting,
                      onTap: controller.openJsonPreview,
                    ),
                    DocumentActionItem(
                      label: 'details.exportPdf'.tr,
                      icon: Icons.picture_as_pdf_outlined,
                      isLoading: controller.isExportingPdf.value,
                      isEnabled: !controller.isExportingWord.value &&
                          !controller.isExportingExcel.value,
                      onTap: controller.exportPdf,
                    ),
                    DocumentActionItem(
                      label: 'details.exportWord'.tr,
                      icon: Icons.description_outlined,
                      isLoading: controller.isExportingWord.value,
                      isEnabled: !controller.isExportingPdf.value &&
                          !controller.isExportingExcel.value,
                      onTap: controller.exportWord,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DocumentStatisticsSection(
                  characters: controller.characterCount,
                  words: controller.wordCount,
                  lines: controller.lineCount,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('details.deleteTitle'.tr),
        content: Text('details.deleteBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common.delete'.tr,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteDocument();
    }
  }
}
