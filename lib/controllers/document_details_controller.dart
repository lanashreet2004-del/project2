import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/history_model.dart';
import '../models/ocr_result_model.dart';
import '../models/json_preview_args.dart';
import '../repositories/history_repository.dart';
import '../repositories/pdf_export_repository.dart';
import '../repositories/word_export_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Presentation logic for a single saved document.
class DocumentDetailsController extends BaseController {
  DocumentDetailsController({
    required HistoryRepository repository,
    required PdfExportRepository pdfExportRepository,
    required WordExportRepository wordExportRepository,
    required HistoryModel document,
  })  : _repository = repository,
        _pdfExportRepository = pdfExportRepository,
        _wordExportRepository = wordExportRepository {
    this.document.value = document;
  }

  final HistoryRepository _repository;
  final PdfExportRepository _pdfExportRepository;
  final WordExportRepository _wordExportRepository;

  final Rxn<HistoryModel> document = Rxn<HistoryModel>();
  final RxBool isEdited = false.obs;
  final RxBool isExported = false.obs;
  final RxBool isExportingPdf = false.obs;
  final RxBool isExportingWord = false.obs;

  List<String> get statusBadges {
    final badges = <String>['Processed'];
    if (isEdited.value) badges.add('Edited');
    if (isExported.value) badges.add('Exported');
    return badges;
  }

  String get exportStatus => statusBadges.join(', ');

  int get characterCount => document.value?.extractedText.length ?? 0;

  int get wordCount {
    final text = document.value?.extractedText.trim() ?? '';
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get lineCount {
    final text = document.value?.extractedText ?? '';
    if (text.isEmpty) return 0;
    return text.split('\n').length;
  }

  Future<void> openTextEditor() async {
    final current = document.value;
    if (current == null) return;

    final updated = await Get.toNamed(
      AppRoutes.textEditor,
      arguments: _toOcrResult(current),
    );

    if (updated is! OcrResultModel) return;

    final saved = current.copyWith(extractedText: updated.extractedText);
    await runAsync(() => _repository.saveDocument(saved));
    document.value = saved;
    isEdited.value = true;
  }

  Future<void> openJsonPreview() async {
    final current = document.value;
    if (current == null) return;

    final exported = await Get.toNamed(
      AppRoutes.jsonPreview,
      arguments: JsonPreviewArgs(
        document: current,
        status: exportStatus,
        sourceType: 'unknown',
        characterCount: characterCount,
        wordCount: wordCount,
        lineCount: lineCount,
      ),
    );

    if (exported == true) {
      isExported.value = true;
    }
  }

  Future<void> exportPdf() async {
    final current = document.value;
    if (current == null || isExportingPdf.value) return;

    isExportingPdf.value = true;
    clearError();

    try {
      final file = await _pdfExportRepository.exportDocumentToPdf(
        current,
        status: exportStatus,
      );

      if (file == null) {
        setError('Failed to export PDF');
        Get.snackbar(
          'Export PDF',
          'Could not export PDF file.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isExported.value = true;

      Get.snackbar(
        'Export PDF',
        'PDF exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _showPdfExportSuccessDialog(file);
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Export PDF',
        'Could not export PDF file.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExportingPdf.value = false;
    }
  }

  Future<void> exportWord() async {
    final current = document.value;
    if (current == null || isExportingWord.value) return;

    isExportingWord.value = true;
    clearError();

    try {
      final file = await _wordExportRepository.exportDocumentToWord(current);

      if (file == null) {
        setError('Failed to export Word document');
        Get.snackbar(
          'Export Word',
          'Could not export Word file.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isExported.value = true;
      _showWordExportSuccessDialog(file);
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Export Word',
        'Could not export Word file.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExportingWord.value = false;
    }
  }

  void _showWordExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Word exported successfully'),
        content: Text(
          file.path,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _wordExportRepository.openExportedFile(file);
            },
            child: const Text('Open File'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _wordExportRepository.shareExportedFile(file);
            },
            child: const Text('Share File'),
          ),
          TextButton(
            onPressed: Get.back,
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showPdfExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('PDF exported successfully'),
        content: Text(
          file.path,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _pdfExportRepository.openExportedFile(file);
            },
            child: const Text('Open File'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _pdfExportRepository.shareExportedFile(file);
            },
            child: const Text('Share File'),
          ),
          TextButton(
            onPressed: Get.back,
            child: const Text('Close'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> deleteDocument() async {
    final id = document.value?.id;
    if (id == null) return;

    await runAsync(() => _repository.deleteDocument(id));
    Get.back();
  }

  void openFullScreenPreview() {
    final path = document.value?.imagePath;
    if (path == null || path.isEmpty) return;

    Get.toNamed(
      AppRoutes.documentImagePreview,
      arguments: {'imagePath': path},
    );
  }

  OcrResultModel _toOcrResult(HistoryModel history) {
    return OcrResultModel(
      id: history.id,
      extractedText: history.extractedText,
      confidence: history.confidence,
      processedAt: history.createdAt,
      imagePath: history.imagePath,
    );
  }
}
