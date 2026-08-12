import 'package:get/get.dart';

import '../../controllers/processing_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../repositories/ocr_repository.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessingController>(
      () => ProcessingController(
        ocrRepository: Get.find<OcrRepository>(),
        uploadController: Get.find<UploadController>(),
      ),
    );
  }
}
