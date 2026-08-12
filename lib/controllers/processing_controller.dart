import 'package:get/get.dart';

import '../repositories/ocr_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'upload_controller.dart';

/// Handles OCR processing presentation and navigation to results.
class ProcessingController extends BaseController {
  ProcessingController({
    required OcrRepository ocrRepository,
    required UploadController uploadController,
  })  : _ocrRepository = ocrRepository,
        _uploadController = uploadController;

  final OcrRepository _ocrRepository;
  final UploadController _uploadController;

  final RxString statusText = 'Preparing image...'.obs;

  static const _statusSteps = [
    'Preparing image...',
    'Analyzing document...',
    'Extracting text...',
  ];

  @override
  void onInit() {
    super.onInit();
    startProcessing();
  }

  Future<void> startProcessing() async {
    final imagePath = _uploadController.editedImagePath.value;
    if (imagePath == null) {
      setError('No image to process');
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.back();
      return;
    }

    await runAsync(() async {
      for (var i = 0; i < _statusSteps.length; i++) {
        statusText.value = _statusSteps[i];
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      final result = await _ocrRepository.processImage(imagePath: imagePath);
      _uploadController.setOcrResult(result);

      Get.offNamed(
        AppRoutes.result,
        arguments: {'resultId': result['id']},
      );
    });
  }
}
