import 'package:get/get.dart';

import '../../controllers/word_files_controller.dart';
import '../../repositories/word_files_repository.dart';

class WordFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WordFilesController>(
      () => WordFilesController(
        repository: Get.find<WordFilesRepository>(),
      ),
    );
  }
}
