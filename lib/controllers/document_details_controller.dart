import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/api_exception.dart';
import '../models/history_model.dart';
import '../models/ocr_result_model.dart';
import '../models/json_preview_args.dart';
import '../repositories/history_repository.dart';
import '../repositories/pdf_export_repository.dart';
import '../repositories/pdf_files_repository.dart';
import '../repositories/word_export_repository.dart';
import '../repositories/word_files_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Presentation logic for a single saved document.
class DocumentDetailsController extends BaseController {
  DocumentDetailsController({
    required HistoryRepository repository,
    required PdfExportRepository pdfExportRepository,
    required PdfFilesRepository pdfFilesRepository,
    required WordExportRepository wordExportRepository,
    required WordFilesRepository wordFilesRepository,
    required HistoryModel document,
  })  : _repository = repository,
        _pdfExportRepository = pdfExportRepository,
        _pdfFilesRepository = pdfFilesRepository,
        _wordExportRepository = wordExportRepository,
        _wordFilesRepository = wordFilesRepository {
    this.document.value = document;
  }

  final HistoryRepository _repository;
  final PdfExportRepository _pdfExportRepository;
  final PdfFilesRepository _pdfFilesRepository;
  final WordExportRepository _wordExportRepository;
  final WordFilesRepository _wordFilesRepository;

  final Rxn<HistoryModel> document = Rxn<HistoryModel>();
  final RxBool isEdited = false.obs;
  final RxBool isExported = false.obs;
  final RxBool isExportingPdf = false.obs;
  final RxBool isExportingWord = false.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureDurableImage();
  }

  /// Migrates a still-valid temp/cache image after the document is opened.
  /// Does not run during camera/gallery capture.
  Future<void> _ensureDurableImage() async {
    final current = document.value;
    if (current == null) return;

    final persisted = await _repository.ensurePersistedImage(current);
    if (persisted.imagePath != current.imagePath) {
      document.value = persisted;
    }
  }

  List<String> get statusBadges {
    final badges = <String>['details.badgeProcessed'];
    if (isEdited.value) badges.add('details.badgeEdited');
    if (isExported.value) badges.add('details.badgeExported');
    return badges;
  }

  String get exportStatus {
    final parts = <String>['Processed'];
    if (isEdited.value) parts.add('Edited');
    if (isExported.value) parts.add('Exported');
    return parts.join(', ');
  }

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
    final persisted = await runAsync(() => _repository.saveDocument(saved));
    document.value = persisted ?? saved;
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
      final file = await _pdfExportRepository.exportDocumentToPdf(current);

      if (file == null) {
        setError('details.exportPdfFailedTitle'.tr);
        Get.snackbar(
          'details.exportPdf'.tr,
          'details.exportPdfFailed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final title = _pdfExportRepository.documentTitleOf(current);
      try {
        await _pdfFilesRepository.registerExportedPdf(
          file: file,
          document: current,
          documentTitle: title,
        );
      } catch (_) {
        // Export succeeded; library registration failure should not block UX.
      }

      isExported.value = true;

      Get.snackbar(
        'details.exportPdf'.tr,
        'details.exportPdfSuccess'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      _showPdfExportSuccessDialog(file);
    } on ApiException catch (e) {
      setError(e.message);
      Get.snackbar(
        'details.exportPdf'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'details.exportPdf'.tr,
        'details.exportPdfFailed'.tr,
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
        setError('details.exportWordFailedTitle'.tr);
        Get.snackbar(
          'details.exportWord'.tr,
          'details.exportWordFailed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final title = _wordExportRepository.documentTitleOf(current);
      try {
        await _wordFilesRepository.registerExportedWord(
          file: file,
          document: current,
          documentTitle: title,
        );
      } catch (_) {
        // Export succeeded; library registration failure should not block UX.
      }

      isExported.value = true;
      _showWordExportSuccessDialog(file);
    } on ApiException catch (e) {
      setError(e.message);
      Get.snackbar(
        'details.exportWord'.tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'details.exportWord'.tr,
        'details.exportWordFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExportingWord.value = false;
    }
  }

  void _showWordExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('details.exportWordSuccess'.tr),
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
            child: Text('details.openFile'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _wordExportRepository.shareExportedFile(file);
            },
            child: Text('details.shareFile'.tr),
          ),
          TextButton(
            onPressed: Get.back,
            child: Text('common.close'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showPdfExportSuccessDialog(File file) {
    Get.dialog<void>(
      AlertDialog(
        title: Text('details.exportPdfSuccess'.tr),
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
            child: Text('details.openFile'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _pdfExportRepository.shareExportedFile(file);
            },
            child: Text('details.shareFile'.tr),
          ),
          TextButton(
            onPressed: Get.back,
            child: Text('common.close'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> deleteDocument() async {
    final id = document.value?.id;
    if (id == null) return;

    final backendId = HistoryRepository.parseBackendId(id);
    if (backendId == null) {
      setError('Invalid document id');
      return;
    }

    await runAsync(() => _repository.deleteOcrRecord(backendId));
    if (hasError) return;
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
      processedAt: history.createdAt,
      imagePath: history.imagePath,
    );
  }
}
