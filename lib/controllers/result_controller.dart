import 'package:get/get.dart';

import '../models/history_model.dart';
import '../models/ocr_result_model.dart';
import '../models/image_pick_source.dart';
import '../repositories/history_repository.dart';
import '../repositories/image_repository.dart';
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

  void applyEditedResult(OcrResultModel updated) {
    result.value = updated;
    _uploadController.setOcrResult(updated.toOcrMap());
  }

  HistoryModel _historyFromOcrResult(OcrResultModel ocrResult) {
    return HistoryModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      imagePath: ocrResult.imagePath,
      extractedText: ocrResult.extractedText,
      createdAt: DateTime.now(),
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
