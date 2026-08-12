import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/document_details_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/document_actions_grid.dart';
import 'widgets/document_details_preview.dart';
import 'widgets/document_extracted_text_card.dart';
import 'widgets/document_info_card.dart';
import 'widgets/document_statistics_section.dart';

/// Document details screen — UI only.
class DocumentDetailsView extends GetView<DocumentDetailsController> {
  const DocumentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('Document Details'),
        centerTitle: true,
      ),
      body: Obx(() {
        final document = controller.document.value;
        if (document == null) {
          return const Center(child: Text('Document not found'));
        }

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
                DocumentInfoCard(
                  documentId: document.id,
                  savedDate: _formatDateTime(document.createdAt),
                  confidence: document.confidence,
                  statusBadges: controller.statusBadges,
                ),
                const SizedBox(height: 16),
                DocumentExtractedTextCard(text: document.extractedText),
                const SizedBox(height: 20),
                DocumentActionsGrid(
                  actions: [
                    DocumentActionItem(
                      label: 'Edit Text',
                      icon: Icons.edit_outlined,
                      onTap: controller.openTextEditor,
                    ),
                    DocumentActionItem(
                      label: 'Export JSON',
                      icon: Icons.code,
                      onTap: controller.openJsonPreview,
                    ),
                    DocumentActionItem(
                      label: 'Export PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: controller.exportPdf,
                    ),
                    DocumentActionItem(
                      label: 'Export Word',
                      icon: Icons.description_outlined,
                      onTap: controller.exportWord,
                    ),
                    DocumentActionItem(
                      label: 'Delete Document',
                      icon: Icons.delete_outline,
                      isDestructive: true,
                      onTap: () => _confirmDelete(context),
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

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete document?'),
        content: const Text(
          'This document will be permanently removed from My Documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
