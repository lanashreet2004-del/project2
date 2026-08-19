import 'package:get/get.dart';

import '../../controllers/json_files_controller.dart';
import '../../repositories/json_files_repository.dart';

class JsonFilesBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<JsonFilesController>()) {
      Get.find<JsonFilesController>().loadJsonFiles();
      return;
    }
    Get.lazyPut<JsonFilesController>(
      () => JsonFilesController(
        repository: Get.find<JsonFilesRepository>(),
      ),
    );
  }
}
