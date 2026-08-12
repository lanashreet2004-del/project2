import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/json_preview_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';
import 'widgets/json_code_block.dart';
import 'widgets/json_stats_chips.dart';
import 'widgets/json_validation_card.dart';

/// JSON preview and validation screen — UI only.
class JsonPreviewView extends GetView<JsonPreviewController> {
  const JsonPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = controller.args;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        title: const Text('JSON Preview'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.copyJson,
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy JSON',
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 900,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const JsonPreviewHeader(),
                    const SizedBox(height: 16),
                    JsonValidationCard(validation: controller.validation),
                    const SizedBox(height: 16),
                    JsonStatsChips(
                      characterCount: args.characterCount,
                      wordCount: args.wordCount,
                      lineCount: args.lineCount,
                      confidence: args.document.confidence,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Formatted JSON',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    JsonCodeBlock(jsonText: controller.prettyJson),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.copyJson,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy JSON'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => FilledButton.icon(
                        onPressed: !controller.canExport ||
                                controller.isExporting.value
                            ? null
                            : controller.exportJson,
                        icon: controller.isExporting.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          controller.isExporting.value
                              ? 'Exporting...'
                              : 'Export JSON',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed:
                          controller.canExport ? controller.shareJson : null,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share JSON'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
