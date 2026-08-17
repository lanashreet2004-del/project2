import 'package:get/get.dart';

import '../models/excel_file_model.dart';
import '../repositories/excel_files_repository.dart';
import '../core/navigation/main_navigation.dart';
import 'base_controller.dart';

/// Presentation logic for the local Excel Files library.
class ExcelFilesController extends BaseController {
  ExcelFilesController({required ExcelFilesRepository repository})
      : _repository = repository;

  final ExcelFilesRepository _repository;

  final RxList<ExcelFileModel> excelFiles = <ExcelFileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExcelFiles();
  }

  Future<void> loadExcelFiles() async {
    final data = await runAsync(() => _repository.getExcelFiles());
    if (data != null) excelFiles.assignAll(data);
  }

  Future<void> openExcel(ExcelFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'excelFiles.title'.tr,
          'excelFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.openExcel(item);
    } catch (_) {
      setError('excelFiles.openFailed'.tr);
      Get.snackbar(
        'excelFiles.title'.tr,
        'excelFiles.openFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareExcel(ExcelFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'excelFiles.title'.tr,
          'excelFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.shareExcel(item);
    } catch (_) {
      setError('excelFiles.shareFailed'.tr);
      Get.snackbar(
        'excelFiles.title'.tr,
        'excelFiles.shareFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteExcel(String id) async {
    clearError();
    try {
      await _repository.deleteExcel(id);
      excelFiles.removeWhere((item) => item.id == id);
      Get.snackbar(
        'excelFiles.title'.tr,
        'excelFiles.deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      setError('excelFiles.deleteFailed'.tr);
      Get.snackbar(
        'excelFiles.title'.tr,
        'excelFiles.deleteFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeStaleEntry(String id) async {
    await _repository.removeStaleEntry(id);
    excelFiles.removeWhere((item) => item.id == id);
    Get.snackbar(
      'excelFiles.title'.tr,
      'excelFiles.staleRemoved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<bool> fileExists(ExcelFileModel item) {
    return _repository.fileExists(item);
  }

  void goHome() {
    MainNavigation.openTab(MainNavigation.home);
  }
}
