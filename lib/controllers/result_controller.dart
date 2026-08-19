import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/api_exception.dart';
import '../models/history_model.dart';
import '../models/image_pick_source.dart';
import '../models/ocr_result_model.dart';
import '../models/text_editor_args.dart';
import '../repositories/excel_export_repository.dart';
import '../repositories/excel_files_repository.dart';
import '../repositories/history_repository.dart';
import '../repositories/image_repository.dart';
import '../repositories/pdf_export_repository.dart';
import '../repositories/pdf_files_repository.dart';
import '../repositories/result_repository.dart';
import '../repositories/word_export_repository.dart';
import '../repositories/word_files_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'home_controller.dart';
import 'upload_controller.dart';

/// Controller for OCR result presentation logic.
class ResultController extends BaseController {
  ResultController({
    required ResultRepository repository,
    required HistoryRepository historyRepository,
    required UploadController uploadController,
    required PdfExportRepository pdfExportRepository,
    required PdfFilesRepository pdfFilesRepository,
    required WordExportRepository wordExportRepository,
    required WordFilesRepository wordFilesRepository,
    required ExcelExportRepository excelExportRepository,
    required ExcelFilesRepository excelFilesRepository,
  })  : _repository = repository,
        _historyRepository = historyRepository,
        _uploadController = uploadController,
        _pdfExportRepository = pdfExportRepository,
        _pdfFilesRepository = pdfFilesRepository,
        _wordExportRepository = wordExportRepository,
        _wordFilesRepository = wordFilesRepository,
        _excelExportRepository = excelExportRepository,
        _excelFilesRepository = excelFilesRepository;

  final ResultRepository _repository;
  final HistoryRepository _historyRepository;
  final UploadController _uploadController;
  final PdfExportRepository _pdfExportRepository;
  final PdfFilesRepository _pdfFilesRepository;
  final WordExportRepository _wordExportRepository;
  final WordFilesRepository _wordFilesRepository;
  final ExcelExportRepository _excelExportRepository;
  final ExcelFilesRepository _excelFilesRepository;

  final Rxn<OcrResultModel> result = Rxn<OcrResultModel>();
  final RxBool isSaving = false.obs;
  final RxBool isExportingPdf = false.obs;
  final RxBool isExportingWord = false.obs;
  final RxBool isExportingExcel = false.obs;
  String? resultId;

  bool get isExporting =>
      isExportingPdf.value || isExportingWord.value || isExportingExcel.value;

  @override
  void onReady() {
    super.onReady();
    resultId = _routeArgs()?['resultId'] as String?;
    loadResult();
  }

  Future<void> loadResult() async {
    final args = _routeArgs();
    final historyDocument = args?['historyDocument'];

    if (historyDocument is HistoryModel) {
      result.value = _ocrResultFromHistory(historyDocument);
      return;
    }

    final ocrData = _uploadController.ocrResult.value ?? _ocrDataFromArgs(args);
    final imagePath = _nonEmptyPath(_uploadController.editedImagePath.value) ??
        _nonEmptyPath(args?['imagePath']);
    final id = resultId ??
        ocrData?['id'] as String? ??
        args?['resultId'] as String? ??
        'default';

    if (ocrData == null || !ImageRepository.isReadableImage(imagePath)) {
      result.value = null;
      setError('result.noResultBody'.tr);
      return;
    }

    if (_uploadController.editedImagePath.value != imagePath) {
      _uploadController.setEditedImage(
        imagePath!,
        source: _uploadController.imageSource.value ?? ImagePickSource.gallery,
      );
    }
    if (_uploadController.ocrResult.value == null) {
      _uploadController.setOcrResult(ocrData);
    }

    final data = await runAsync(
      () => _repository.getResult(
        id: id,
        ocrData: ocrData,
        imagePath: imagePath,
      ),
    );

    if (data != null) {
      result.value = data;
    }
  }

  Future<void> openTextEditor() async {
    if (isSaving.value || isExporting) return;

    final current = result.value;
    if (current == null) return;

    final updated = await Get.toNamed(
      AppRoutes.textEditor,
      arguments: TextEditorArgs(
        ocrResult: current,
        persistToBackend: true,
      ),
    );

    if (updated is OcrResultModel) {
      applyEditedResult(updated);
    }
  }

  void applyEditedResult(OcrResultModel updated) {
    result.value = updated;
    result.refresh();
    _uploadController.setOcrResult(updated.toOcrMap());
  }

  Future<void> saveDocument() async {
    final current = result.value;
    if (current == null || isSaving.value || isExporting) return;

    if (!ImageRepository.isReadableImage(current.imagePath) ||
        current.extractedText.trim().isEmpty) {
      setError('result.saveFailed'.tr);
      Get.snackbar(
        'common.error'.tr,
        'result.saveFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    clearError();

    try {
      final historyItem = _historyFromOcrResult(current);
      final saved = await _historyRepository.saveDocument(historyItem);

      if (!ImageRepository.isReadableImage(saved.imagePath)) {
        throw Exception('Saved image is missing');
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadDocuments();
      }

      Get.snackbar(
        'result.savedTitle'.tr,
        'result.savedBody'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      await Get.offNamed(
        AppRoutes.documentDetails,
        arguments: saved,
      );
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'common.error'.tr,
        'result.saveFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> exportPdf() => _export(_ResultExportKind.pdf);

  Future<void> exportWord() => _export(_ResultExportKind.word);

  Future<void> exportExcel() => _export(_ResultExportKind.excel);

  /// Maps an OCR result to local history.
  ///
  /// Backend OCR PKs (e.g. `"29"`) are preserved so Document Details export
  /// can call `/api/export-ocr/{id}/`. Legacy/invalid IDs keep a local `doc_`
  /// prefix and are never sent to `<int:pk>` endpoints.
  HistoryModel _historyFromOcrResult(OcrResultModel ocrResult) {
    return HistoryModel(
      id: persistableHistoryId(ocrResult.id),
      imagePath: ocrResult.imagePath,
      extractedText: ocrResult.extractedText,
      createdAt: DateTime.now(),
    );
  }

  @visibleForTesting
  static String persistableHistoryId(String ocrResultId) {
    final trimmed = ocrResultId.trim();
    if (HistoryRepository.parseBackendId(trimmed) != null) {
      return trimmed;
    }
    if (trimmed.startsWith('doc_')) {
      return trimmed;
    }
    return 'doc_${DateTime.now().millisecondsSinceEpoch}';
  }

  HistoryModel? _historyForBackendExport(OcrResultModel ocrResult) {
    if (HistoryRepository.parseBackendId(ocrResult.id) == null) {
      return null;
    }
    return HistoryModel(
      id: ocrResult.id.trim(),
      imagePath: ocrResult.imagePath,
      extractedText: ocrResult.extractedText,
      createdAt: ocrResult.processedAt,
    );
  }

  Future<void> _export(_ResultExportKind kind) async {
    final current = result.value;
    if (current == null || isSaving.value || isExporting) return;

    final document = _historyForBackendExport(current);
    if (document == null) {
      setError('result.exportInvalidIdBody'.tr);
      Get.snackbar(
        'result.exportInvalidIdTitle'.tr,
        'result.exportInvalidIdBody'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final flag = _exportingFlag(kind);
    flag.value = true;
    clearError();

    try {
      final file = await _runExport(kind, document);
      if (file == null) {
        setError(_failedTitle(kind).tr);
        Get.snackbar(
          _label(kind).tr,
          _failedBody(kind).tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        await _registerExport(kind, file, document);
      } catch (_) {
        // Export succeeded; library registration failure should not block UX.
      }

      Get.snackbar(
        _label(kind).tr,
        _successTitle(kind).tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      _showExportSuccessDialog(kind, file);
    } on ApiException catch (e) {
      setError(e.message);
      Get.snackbar(
        _label(kind).tr,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        _label(kind).tr,
        _failedBody(kind).tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      flag.value = false;
    }
  }

  RxBool _exportingFlag(_ResultExportKind kind) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return isExportingPdf;
      case _ResultExportKind.word:
        return isExportingWord;
      case _ResultExportKind.excel:
        return isExportingExcel;
    }
  }

  Future<File?> _runExport(_ResultExportKind kind, HistoryModel document) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return _pdfExportRepository.exportDocumentToPdf(document);
      case _ResultExportKind.word:
        return _wordExportRepository.exportDocumentToWord(document);
      case _ResultExportKind.excel:
        return _excelExportRepository.exportDocumentToExcel(document);
    }
  }

  Future<void> _registerExport(
    _ResultExportKind kind,
    File file,
    HistoryModel document,
  ) async {
    switch (kind) {
      case _ResultExportKind.pdf:
        await _pdfFilesRepository.registerExportedPdf(
          file: file,
          document: document,
          documentTitle: _pdfExportRepository.documentTitleOf(document),
        );
      case _ResultExportKind.word:
        await _wordFilesRepository.registerExportedWord(
          file: file,
          document: document,
          documentTitle: _wordExportRepository.documentTitleOf(document),
        );
      case _ResultExportKind.excel:
        await _excelFilesRepository.registerExportedExcel(
          file: file,
          document: document,
          documentTitle: _excelExportRepository.documentTitleOf(document),
        );
    }
  }

  Future<void> _openExported(_ResultExportKind kind, File file) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return _pdfExportRepository.openExportedFile(file);
      case _ResultExportKind.word:
        return _wordExportRepository.openExportedFile(file);
      case _ResultExportKind.excel:
        return _excelExportRepository.openExportedFile(file);
    }
  }

  Future<void> _shareExported(_ResultExportKind kind, File file) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return _pdfExportRepository.shareExportedFile(file);
      case _ResultExportKind.word:
        return _wordExportRepository.shareExportedFile(file);
      case _ResultExportKind.excel:
        return _excelExportRepository.shareExportedFile(file);
    }
  }

  String _label(_ResultExportKind kind) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return 'details.exportPdf';
      case _ResultExportKind.word:
        return 'details.exportWord';
      case _ResultExportKind.excel:
        return 'details.exportExcel';
    }
  }

  String _successTitle(_ResultExportKind kind) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return 'details.exportPdfSuccess';
      case _ResultExportKind.word:
        return 'details.exportWordSuccess';
      case _ResultExportKind.excel:
        return 'details.exportExcelSuccess';
    }
  }

  String _failedTitle(_ResultExportKind kind) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return 'details.exportPdfFailedTitle';
      case _ResultExportKind.word:
        return 'details.exportWordFailedTitle';
      case _ResultExportKind.excel:
        return 'details.exportExcelFailedTitle';
    }
  }

  String _failedBody(_ResultExportKind kind) {
    switch (kind) {
      case _ResultExportKind.pdf:
        return 'details.exportPdfFailed';
      case _ResultExportKind.word:
        return 'details.exportWordFailed';
      case _ResultExportKind.excel:
        return 'details.exportExcelFailed';
    }
  }

  void _showExportSuccessDialog(_ResultExportKind kind, File file) {
    Get.dialog<void>(
      AlertDialog(
        title: Text(_successTitle(kind).tr),
        content: Text(
          file.path,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await _openExported(kind, file);
            },
            child: Text('details.openFile'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _shareExported(kind, file);
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

  OcrResultModel _ocrResultFromHistory(HistoryModel history) {
    return OcrResultModel(
      id: history.id,
      extractedText: history.extractedText,
      processedAt: history.createdAt,
      imagePath: history.imagePath,
    );
  }

  Map<String, dynamic>? _routeArgs() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) return args;
    if (args is Map) return Map<String, dynamic>.from(args);
    return null;
  }

  Map<String, dynamic>? _ocrDataFromArgs(Map<String, dynamic>? args) {
    final raw = args?['ocrData'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  String? _nonEmptyPath(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }
}

enum _ResultExportKind { pdf, word, excel }
