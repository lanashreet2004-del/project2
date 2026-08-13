import 'package:get/get.dart';

import '../../controllers/json_files_controller.dart';
import '../../repositories/json_files_repository.dart';

class JsonFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JsonFilesController>(
      () => JsonFilesController(
        repository: Get.find<JsonFilesRepository>(),
      ),
    );
  }
}
