import 'package:get/get.dart';

import '../../controllers/documents_controller.dart';
import '../../repositories/history_repository.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentsController>(
      () => DocumentsController(repository: Get.find<HistoryRepository>()),
    );
  }
}
