import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/json_export_validation_result.dart';
import '../models/json_preview_args.dart';
import '../repositories/json_export_repository.dart';
import '../repositories/json_files_repository.dart';
import 'base_controller.dart';

/// Presentation logic for JSON preview, validation, and export actions.
class JsonPreviewController extends BaseController {
  JsonPreviewController({
    required JsonExportRepository repository,
    required JsonFilesRepository jsonFilesRepository,
    required JsonPreviewArgs args,
  })  : _repository = repository,
        _jsonFilesRepository = jsonFilesRepository,
        _args = args {
    _initializePreview();
  }

  final JsonExportRepository _repository;
  final JsonFilesRepository _jsonFilesRepository;
  final JsonPreviewArgs _args;

  late final Map<String, dynamic> payload;
  late final JsonExportValidationResult validation;
  late final String prettyJson;

  final RxBool isExporting = false.obs;

  JsonPreviewArgs get args => _args;

  bool get canExport => validation.isValid;

  void _initializePreview() {
    payload = _repository.buildExportPayload(
      document: _args.document,
      status: _args.status,
      sourceType: _args.sourceType,
      wordCount: _args.wordCount,
      characterCount: _args.characterCount,
      lineCount: _args.lineCount,
    );
    validation = _repository.validateExportPayload(payload);
    prettyJson = _repository.formatPrettyJson(payload);
  }

  Future<void> copyJson() async {
    await Clipboard.setData(ClipboardData(text: prettyJson));
    Get.snackbar(
      'jsonPreview.copiedTitle'.tr,
      'jsonPreview.copiedBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> exportJson() async {
    if (!canExport || isExporting.value) return;

    isExporting.value = true;
    clearError();

    try {
      final file = await _repository.exportDocumentToJson(
        document: _args.document,
        status: _args.status,
        sourceType: _args.sourceType,
        wordCount: _args.wordCount,
        characterCount: _args.characterCount,
        lineCount: _args.lineCount,
      );

      if (file == null) {
        Get.snackbar(
          'jsonPreview.export'.tr,
          'jsonPreview.exportFailed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        await _jsonFilesRepository.registerExportedJson(
          file: file,
          document: _args.document,
          documentTitle: _documentTitle(_args.document.extractedText),
        );
      } catch (_) {
        // Export succeeded; library registration failure should not block UX.
      }

      Get.snackbar(
        'jsonPreview.export'.tr,
        'jsonPreview.exportSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      _showExportSuccessDialog(file);
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'jsonPreview.export'.tr,
        'jsonPreview.exportFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> shareJson() async {
    if (!canExport) {
      Get.snackbar(
        'jsonPreview.share'.tr,
        'jsonPreview.fixBeforeShare'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _repository.shareJsonPayload(payload);
  }

  void _showExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('jsonPreview.exportDialogTitle'.tr),
        content: Text(
          file.path,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _repository.openExportFolder(highlightFile: file);
            },
            child: Text('jsonPreview.openFolder'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _repository.shareExportedFile(file);
              Get.back(result: true);
            },
            child: Text('details.shareFile'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: Text('common.close'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  String _documentTitle(String extractedText) {
    final trimmed = extractedText.trim();
    if (trimmed.isEmpty) return 'Untitled Document';

    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.isEmpty) return 'Untitled Document';

    const maxLength = 80;
    if (firstLine.length <= maxLength) return firstLine;
    return '${firstLine.substring(0, maxLength)}...';
  }
}
