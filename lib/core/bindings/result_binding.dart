import 'package:get/get.dart';

import '../../controllers/result_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../repositories/history_repository.dart';
import '../../repositories/result_repository.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(
      () => ResultController(
        repository: Get.find<ResultRepository>(),
        historyRepository: Get.find<HistoryRepository>(),
        uploadController: Get.find<UploadController>(),
      ),
    );
  }
}
