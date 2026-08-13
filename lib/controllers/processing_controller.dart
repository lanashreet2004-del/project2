import 'package:get/get.dart';

import '../repositories/ocr_repository.dart';
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
  void onInit() {
    super.onInit();
    startProcessing();
  }

  Future<void> startProcessing() async {
    hasFailed.value = false;
    clearError();
    canCancel.value = true;

    final imagePath = _uploadController.editedImagePath.value;
    if (imagePath == null) {
      hasFailed.value = true;
      statusText.value = 'processing.failed';
      setError('processing.noImage'.tr);
      return;
    }

    await runAsync(() async {
      for (var i = 0; i < _statusStepKeys.length; i++) {
        statusText.value = _statusStepKeys[i];
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      final result = await _ocrRepository.processImage(imagePath: imagePath);
      if (result['text'] == null && result['id'] == null) {
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
}
