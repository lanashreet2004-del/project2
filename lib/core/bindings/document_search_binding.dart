import 'package:get/get.dart';

import '../../controllers/document_search_controller.dart';
import '../../repositories/history_repository.dart';

class DocumentSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentSearchController>(
      () => DocumentSearchController(
        historyRepository: Get.find<HistoryRepository>(),
      ),
    );
  }
}
