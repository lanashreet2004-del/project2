import 'package:get/get.dart';

import '../models/history_model.dart';
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
    final data = await runAsync(() => _repository.getDocuments());
    if (data != null) documents.assignAll(data);
  }

  Future<void> deleteDocument(String id) async {
    await runAsync(() => _repository.deleteDocument(id));
    documents.removeWhere((doc) => doc.id == id);
  }

  Future<void> clearAll() async {
    await runAsync(() => _repository.clearAll());
    documents.clear();
  }

  Future<void> openDocument(HistoryModel item) async {
    await Get.toNamed(AppRoutes.documentDetails, arguments: item);
    await loadDocuments();
  }

  void scanNewDocument() {
    Get.offAllNamed(AppRoutes.home);
  }
}
