import 'package:get/get.dart';

import '../models/pdf_file_model.dart';
import '../repositories/pdf_files_repository.dart';
import '../core/navigation/main_navigation.dart';
import 'base_controller.dart';

/// Presentation logic for the local PDF Files library.
class PdfFilesController extends BaseController {
  PdfFilesController({required PdfFilesRepository repository})
      : _repository = repository;

  final PdfFilesRepository _repository;

  final RxList<PdfFileModel> pdfFiles = <PdfFileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPdfFiles();
  }

  Future<void> loadPdfFiles() async {
    final data = await runAsync(() => _repository.getPdfFiles());
    if (data != null) pdfFiles.assignAll(data);
  }

  Future<void> openPdf(PdfFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'pdfFiles.title'.tr,
          'pdfFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.openPdf(item);
    } catch (_) {
      setError('pdfFiles.openFailed'.tr);
      Get.snackbar(
        'pdfFiles.title'.tr,
        'pdfFiles.openFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> sharePdf(PdfFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'pdfFiles.title'.tr,
          'pdfFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.sharePdf(item);
    } catch (_) {
      setError('pdfFiles.shareFailed'.tr);
      Get.snackbar(
        'pdfFiles.title'.tr,
        'pdfFiles.shareFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deletePdf(String id) async {
    clearError();
    try {
      await _repository.deletePdf(id);
      pdfFiles.removeWhere((item) => item.id == id);
      Get.snackbar(
        'pdfFiles.title'.tr,
        'pdfFiles.deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      setError('pdfFiles.deleteFailed'.tr);
      Get.snackbar(
        'pdfFiles.title'.tr,
        'pdfFiles.deleteFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeStaleEntry(String id) async {
    await _repository.removeStaleEntry(id);
    pdfFiles.removeWhere((item) => item.id == id);
    Get.snackbar(
      'pdfFiles.title'.tr,
      'pdfFiles.staleRemoved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<bool> fileExists(PdfFileModel item) {
    return _repository.fileExists(item);
  }

  void goHome() {
    MainNavigation.openTab(MainNavigation.home);
  }
}
