import 'package:get/get.dart';

import '../../controllers/text_editor_controller.dart';
import '../../models/ocr_result_model.dart';
import '../../models/text_editor_args.dart';
import '../../repositories/text_edit_repository.dart';

class TextEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextEditorController>(
      () {
        final args = Get.arguments;
        if (args is TextEditorArgs) {
          return TextEditorController(
            repository: Get.find<TextEditRepository>(),
            ocrResult: args.ocrResult,
            persistToBackend: args.persistToBackend,
          );
        }

        return TextEditorController(
          repository: Get.find<TextEditRepository>(),
          ocrResult: args as OcrResultModel,
        );
      },
    );
  }
}
