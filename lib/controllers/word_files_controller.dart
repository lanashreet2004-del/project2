import 'package:get/get.dart';

import '../models/word_file_model.dart';
import '../repositories/word_files_repository.dart';
import '../core/navigation/main_navigation.dart';
import 'base_controller.dart';
import 'scoped_file_list_mixin.dart';

/// Presentation logic for the local Word Files library.
class WordFilesController extends BaseController with ScopedFileListMixin {
  WordFilesController({required WordFilesRepository repository})
      : _repository = repository;

  final WordFilesRepository _repository;

  final RxList<WordFileModel> wordFiles = <WordFileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWordFiles();
  }

  void clearFiles() => clearScopedList(wordFiles);

  Future<void> loadWordFiles() {
    return reloadScopedList(wordFiles, _repository.getWordFiles);
  }

  Future<void> openWord(WordFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'wordFiles.title'.tr,
          'wordFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.openWord(item);
    } catch (_) {
      setError('wordFiles.openFailed'.tr);
      Get.snackbar(
        'wordFiles.title'.tr,
        'wordFiles.openFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareWord(WordFileModel item) async {
    clearError();
    try {
      final exists = await _repository.fileExists(item);
      if (!exists) {
        Get.snackbar(
          'wordFiles.title'.tr,
          'wordFiles.missingSnackbar'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      await _repository.shareWord(item);
    } catch (_) {
      setError('wordFiles.shareFailed'.tr);
      Get.snackbar(
        'wordFiles.title'.tr,
        'wordFiles.shareFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteWord(String id) async {
    clearError();
    try {
      await _repository.deleteWord(id);
      wordFiles.removeWhere((item) => item.id == id);
      Get.snackbar(
        'wordFiles.title'.tr,
        'wordFiles.deleted'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      setError('wordFiles.deleteFailed'.tr);
      Get.snackbar(
        'wordFiles.title'.tr,
        'wordFiles.deleteFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeStaleEntry(String id) async {
    await _repository.removeStaleEntry(id);
    wordFiles.removeWhere((item) => item.id == id);
    Get.snackbar(
      'wordFiles.title'.tr,
      'wordFiles.staleRemoved'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<bool> fileExists(WordFileModel item) {
    return _repository.fileExists(item);
  }

  void goHome() {
    MainNavigation.openTab(MainNavigation.home);
  }
}
