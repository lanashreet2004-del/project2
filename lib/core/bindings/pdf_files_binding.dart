import 'package:get/get.dart';

import '../../controllers/pdf_files_controller.dart';
import '../../repositories/pdf_files_repository.dart';

class PdfFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfFilesController>(
      () => PdfFilesController(
        repository: Get.find<PdfFilesRepository>(),
      ),
    );
  }
}
