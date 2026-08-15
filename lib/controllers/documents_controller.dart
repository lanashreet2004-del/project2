import 'package:get/get.dart';

import '../core/utils/api_exception.dart';
import '../models/history_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/history_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Controller for My Documents presentation logic.
class DocumentsController extends BaseController {
  DocumentsController({required HistoryRepository repository})
      : _repository = repository;

  final HistoryRepository _repository;

  final RxList<HistoryModel> documents = <HistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    final data = await runAsync(() => _repository.fetchOcrHistory());
    if (data != null) documents.assignAll(data);
  }

  Future<void> deleteDocument(String id) async {
    if (isLoading.value) return;

    final backendId = HistoryRepository.parseBackendId(id);
    if (backendId == null) {
      setError(ApiException('Invalid document id').message);
      return;
    }

    await runAsync(() => _repository.deleteOcrRecord(backendId));
    if (hasError) return;
    documents.removeWhere((doc) => doc.id == id);
  }

  Future<void> clearAll() async {
    if (isLoading.value) return;

    final auth = Get.find<AuthRepository>();
    if (!auth.isLoggedIn) {
      setError('ocr.authRequiredBody'.tr);
      return;
    }

    final result = await runAsync(() => _repository.deleteAllOcrRecords());
    if (result == null) return;

    documents.assignAll(result.remaining);

    if (result.attempted == 0) {
      return;
    }

    if (result.failed > 0) {
      clearError();
      Get.snackbar(
        'documents.clearTitle'.tr,
        'documents.clearPartialFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    clearError();
    Get.snackbar(
      'documents.cleared'.tr,
      'documents.emptyBody'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> openDocument(HistoryModel item) async {
    await Get.toNamed(AppRoutes.documentDetails, arguments: item);
    await loadDocuments();
  }

  void scanNewDocument() {
    Get.offAllNamed(AppRoutes.home);
  }
}
