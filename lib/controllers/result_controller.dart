import 'package:get/get.dart';

import '../models/history_model.dart';
import '../models/ocr_result_model.dart';
import '../repositories/history_repository.dart';
import '../repositories/result_repository.dart';
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
  })  : _repository = repository,
        _historyRepository = historyRepository,
        _uploadController = uploadController;

  final ResultRepository _repository;
  final HistoryRepository _historyRepository;
  final UploadController _uploadController;

  final Rxn<OcrResultModel> result = Rxn<OcrResultModel>();
  final RxBool isSaving = false.obs;
  String? resultId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    resultId = args?['resultId'] as String?;
    loadResult();
  }

  Future<void> loadResult() async {
    final args = Get.arguments as Map<String, dynamic>?;
    final historyDocument = args?['historyDocument'];

    if (historyDocument is HistoryModel) {
      result.value = _ocrResultFromHistory(historyDocument);
      return;
    }

    final id =
        resultId ?? _uploadController.ocrResult.value?['id'] as String? ?? 'default';
    final ocrData = _uploadController.ocrResult.value;
    final imagePath = _uploadController.editedImagePath.value;

    final data = await runAsync(
      () => _repository.getResult(
        id: id,
        ocrData: ocrData,
        imagePath: imagePath,
      ),
    );

    if (data != null) result.value = data;
  }

  Future<void> openTextEditor() async {
    final current = result.value;
    if (current == null) return;

    final updated = await Get.toNamed(
      AppRoutes.textEditor,
      arguments: current,
    );

    if (updated is OcrResultModel) {
      applyEditedResult(updated);
    }
  }

  Future<void> saveDocument() async {
    final current = result.value;
    if (current == null || isSaving.value) return;

    isSaving.value = true;
    clearError();

    try {
      final historyItem = _historyFromOcrResult(current);
      await _historyRepository.saveDocument(historyItem);

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
        arguments: historyItem,
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

  void applyEditedResult(OcrResultModel updated) {
    result.value = updated;
    _uploadController.setOcrResult(updated.toOcrMap());
  }

  HistoryModel _historyFromOcrResult(OcrResultModel ocrResult) {
    return HistoryModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: ocrResult.imagePath,
      extractedText: ocrResult.extractedText,
      confidence: ocrResult.confidence,
      createdAt: DateTime.now(),
    );
  }

  OcrResultModel _ocrResultFromHistory(HistoryModel history) {
    return OcrResultModel(
      id: history.id,
      extractedText: history.extractedText,
      confidence: history.confidence,
      processedAt: history.createdAt,
      imagePath: history.imagePath,
    );
  }
}
