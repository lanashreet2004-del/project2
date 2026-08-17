import 'package:get/get.dart';

import '../../controllers/excel_files_controller.dart';
import '../../repositories/excel_files_repository.dart';

class ExcelFilesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExcelFilesController>(
      () => ExcelFilesController(
        repository: Get.find<ExcelFilesRepository>(),
      ),
    );
  }
}
