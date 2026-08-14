import 'package:get/get.dart';

import '../models/image_pick_source.dart';
import '../repositories/ocr_repository.dart';
import '../repositories/image_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'upload_controller.dart';

/// Handles OCR processing presentation and navigation to results.
/// Uses mock OCR until a real backend/model is connected.
class ProcessingController extends BaseController {
  ProcessingController({
    required OcrRepository ocrRepository,
    required UploadController uploadController,
  })  : _ocrRepository = ocrRepository,
        _uploadController = uploadController;

  final OcrRepository _ocrRepository;
  final UploadController _uploadController;

  final RxString statusText = 'processing.preparing'.obs;
  final RxBool hasFailed = false.obs;
  final RxBool canCancel = true.obs;

  static const _statusStepKeys = [
    'processing.preparing',
    'processing.analyzing',
    'processing.extracting',
  ];

  @override
  void onReady() {
    super.onReady();
    startProcessing();
  }

  Future<void> startProcessing() async {
    hasFailed.value = false;
    clearError();
    canCancel.value = true;

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
      for (var i = 0; i < _statusStepKeys.length; i++) {
        statusText.value = _statusStepKeys[i];
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      final result = await _ocrRepository.processImage(imagePath: imagePath);
      final text = result['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw Exception('OCR returned an empty result');
      }

      _uploadController.setOcrResult(result);
      canCancel.value = false;
      statusText.value = 'processing.done';

      Get.offNamed(
        AppRoutes.result,
        arguments: {
          'resultId': result['id'],
          'fromProcessing': true,
          'imagePath': imagePath,
          'ocrData': result,
        },
      );
    });

    if (hasError) {
      hasFailed.value = true;
      statusText.value = 'processing.failed';
      canCancel.value = true;
    }
  }

  Future<void> retry() async {
    await startProcessing();
  }

  void cancelProcessing() {
    if (!canCancel.value || isLoading.value) {
      // Allow cancel only when failed or idle; during loading we still allow
      // going back after confirmation via cancelFailedOrIdle.
    }
    Get.back();
  }

  void goBack() {
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
