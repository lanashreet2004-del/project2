import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/json_export_validation_result.dart';
import '../models/json_preview_args.dart';
import '../repositories/json_export_repository.dart';
import 'base_controller.dart';

/// Presentation logic for JSON preview, validation, and export actions.
class JsonPreviewController extends BaseController {
  JsonPreviewController({
    required JsonExportRepository repository,
    required JsonPreviewArgs args,
  })  : _repository = repository,
        _args = args {
    _initializePreview();
  }

  final JsonExportRepository _repository;
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
      'Copied',
      'JSON copied to clipboard.',
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
          'Export JSON',
          'Could not export JSON file.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'Export JSON',
        'JSON exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _showExportSuccessDialog(file);
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Export JSON',
        'Could not export JSON file.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> shareJson() async {
    if (!canExport) {
      Get.snackbar(
        'Share JSON',
        'Fix validation errors before sharing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _repository.shareJsonPayload(payload);
  }

  void _showExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('File exported successfully'),
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
            child: const Text('Open Folder'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _repository.shareExportedFile(file);
              Get.back(result: true);
            },
            child: const Text('Share File'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
            },
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
