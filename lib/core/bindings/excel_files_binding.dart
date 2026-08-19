import 'package:get/get.dart';

import '../../controllers/excel_files_controller.dart';
import '../../repositories/excel_files_repository.dart';

class ExcelFilesBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ExcelFilesController>()) {
      Get.find<ExcelFilesController>().loadExcelFiles();
      return;
    }
    Get.lazyPut<ExcelFilesController>(
      () => ExcelFilesController(
        repository: Get.find<ExcelFilesRepository>(),
      ),
    );
  }
}
