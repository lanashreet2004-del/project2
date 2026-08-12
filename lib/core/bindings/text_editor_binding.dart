import 'package:get/get.dart';

import '../../controllers/text_editor_controller.dart';
import '../../models/ocr_result_model.dart';
import '../../repositories/text_edit_repository.dart';

class TextEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextEditorController>(
      () => TextEditorController(
        repository: Get.find<TextEditRepository>(),
        ocrResult: Get.arguments as OcrResultModel,
      ),
    );
  }
}
