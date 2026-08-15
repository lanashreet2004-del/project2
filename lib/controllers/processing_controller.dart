import 'package:get/get.dart';

import '../core/utils/api_exception.dart';
import '../models/image_pick_source.dart';
import '../models/ocr_status_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/ocr_repository.dart';
import '../repositories/image_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'upload_controller.dart';

/// Handles OCR processing: POST process-ocr, then poll ocr-status.
class ProcessingController extends BaseController {
  ProcessingController({
    required OcrRepository ocrRepository,
    required UploadController uploadController,
    required AuthRepository authRepository,
  })  : _ocrRepository = ocrRepository,
        _uploadController = uploadController,
        _authRepository = authRepository;

  final OcrRepository _ocrRepository;
  final UploadController _uploadController;
  final AuthRepository _authRepository;

  final RxString statusText = 'processing.preparing'.obs;
  final RxBool hasFailed = false.obs;
  final RxBool canCancel = true.obs;

  /// Backend OCR record id from POST /api/process-ocr/.
  int? ocrRecordId;

  static const _pollInterval = Duration(seconds: 2);
  static const _maxPollAttempts = 90;

  bool _cancelled = false;

  @override
  void onReady() {
    super.onReady();
    startProcessing();
  }

  @override
  void onClose() {
    _cancelled = true;
    super.onClose();
  }

  Future<void> startProcessing() async {
    _cancelled = false;
    hasFailed.value = false;
    clearError();
    canCancel.value = true;
    ocrRecordId = null;

    if (!_authRepository.isLoggedIn) {
      hasFailed.value = true;
      statusText.value = 'processing.failed';
      setError('ocr.authRequiredBody'.tr);
      return;
    }

    final resolvedPath = _resolveImagePath();
    if (!ImageRepository.isReadableImage(resolvedPath)) {
      hasFailed.value = true;
      statusText.value = 'processing.failed';
      setError('processing.noImage'.tr);
      return;
    }
    final imagePath = resolvedPath!;

    if (_uploadController.editedImagePath.value != imagePath) {
      _uploadController.setEditedImage(
        imagePath,
        source: _uploadController.imageSource.value ??
            ImagePickSource.fromString(_routeArg('source')),
      );
    }

    await runAsync(() async {
      statusText.value = 'processing.preparing';
      final accepted = await _ocrRepository.processImage(imagePath: imagePath);
      if (_cancelled) return;

      ocrRecordId = accepted.id;
      statusText.value = 'processing.analyzing';

      final completed = await _pollUntilTerminal(accepted.id);
      if (_cancelled) return;

      if (completed.isFailed) {
        throw ApiException(
          completed.errorMessage?.trim().isNotEmpty == true
              ? completed.errorMessage!
              : 'processing.errorBody'.tr,
        );
      }

      final ocrData = completed.toOcrResultMap();
      final text = ocrData['text'] as String? ?? '';
      if (text.trim().isEmpty) {
        throw ApiException('OCR returned an empty result');
      }

      _uploadController.setOcrResult(ocrData);
      canCancel.value = false;
      statusText.value = 'processing.done';

      Get.offNamed(
        AppRoutes.result,
        arguments: {
          'resultId': ocrData['id'],
          'fromProcessing': true,
          'imagePath': imagePath,
          'ocrData': ocrData,
        },
      );
    });

    if (hasError) {
      hasFailed.value = true;
      statusText.value = 'processing.failed';
      canCancel.value = true;
    }
  }

  Future<OcrStatusModel> _pollUntilTerminal(int id) async {
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      if (_cancelled) {
        throw ApiException('Request was cancelled.');
      }

      final status = await _ocrRepository.getStatus(id: id);
      if (status.isPending) {
        statusText.value = 'processing.analyzing';
      } else if (status.isProcessing) {
        statusText.value = 'processing.extracting';
      }

      if (status.isTerminal) {
        return status;
      }

      await Future<void>.delayed(_pollInterval);
    }

    throw ApiException('processing.errorBody'.tr);
  }

  Future<void> retry() async {
    await startProcessing();
  }

  void cancelProcessing() {
    _cancelled = true;
    Get.back();
  }

  void goBack() {
    _cancelled = true;
    Get.back();
  }

  String? _resolveImagePath() {
    final fromController = _uploadController.editedImagePath.value;
    if (ImageRepository.isReadableImage(fromController)) {
      return fromController;
    }
    final fromArgs = _routeArg('imagePath');
    if (ImageRepository.isReadableImage(fromArgs)) {
      return fromArgs;
    }
    return fromController ?? fromArgs;
  }

  String? _routeArg(String key) {
    final args = Get.arguments;
    if (args is Map) {
      final value = args[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
