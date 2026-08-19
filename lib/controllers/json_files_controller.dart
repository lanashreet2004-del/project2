import 'package:get/get.dart';

import '../models/json_file_model.dart';
import '../repositories/json_files_repository.dart';
import '../core/navigation/main_navigation.dart';
import 'base_controller.dart';
import 'scoped_file_list_mixin.dart';

/// Presentation logic for the local JSON Files library.
class JsonFilesController extends BaseController with ScopedFileListMixin {
  JsonFilesController({required JsonFilesRepository repository})
      : _repository = repository;

  final JsonFilesRepository _repository;

  final RxList<JsonFileModel> jsonFiles = <JsonFileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadJsonFiles();
  }

  void clearFiles() => clearScopedList(jsonFiles);

  Future<void> loadJsonFiles() {
    return reloadScopedList(jsonFiles, _repository.getJsonFiles);
  }

  Future<void> openJson(JsonFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'jsonFiles.title'.tr,
          'jsonFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.openJson(item);
    } catch (_) {
      setError('jsonFiles.openFailed'.tr);
      Get.snackbar(
        'jsonFiles.title'.tr,
        'jsonFiles.openFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareJson(JsonFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'jsonFiles.title'.tr,
          'jsonFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.shareJson(item);
    } catch (_) {
      setError('jsonFiles.shareFailed'.tr);
      Get.snackbar(
        'jsonFiles.title'.tr,
        'jsonFiles.shareFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteJson(String id) async {
    clearError();
    try {
      await _repository.deleteJson(id);
      jsonFiles.removeWhere((item) => item.id == id);
      Get.snackbar(
        'jsonFiles.title'.tr,
        'jsonFiles.deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      setError('jsonFiles.deleteFailed'.tr);
      Get.snackbar(
        'jsonFiles.title'.tr,
        'jsonFiles.deleteFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeStaleEntry(String id) async {
    await _repository.removeStaleEntry(id);
    jsonFiles.removeWhere((item) => item.id == id);
    Get.snackbar(
      'jsonFiles.title'.tr,
      'jsonFiles.staleRemoved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<bool> fileExists(JsonFileModel item) {
    return _repository.fileExists(item);
  }

  void goHome() {
    MainNavigation.openTab(MainNavigation.home);
  }
}
