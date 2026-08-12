import 'package:get/get.dart';

import '../../controllers/json_preview_controller.dart';
import '../../models/json_preview_args.dart';
import '../../repositories/json_export_repository.dart';

class JsonPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JsonPreviewController>(
      () => JsonPreviewController(
        repository: Get.find<JsonExportRepository>(),
        args: Get.arguments as JsonPreviewArgs,
      ),
    );
  }
}
