import 'package:get/get.dart';

import '../../controllers/result_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../repositories/excel_export_repository.dart';
import '../../repositories/excel_files_repository.dart';
import '../../repositories/history_repository.dart';
import '../../repositories/pdf_export_repository.dart';
import '../../repositories/pdf_files_repository.dart';
import '../../repositories/result_repository.dart';
import '../../repositories/word_export_repository.dart';
import '../../repositories/word_files_repository.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultController>(
      () => ResultController(
        repository: Get.find<ResultRepository>(),
        historyRepository: Get.find<HistoryRepository>(),
        uploadController: Get.find<UploadController>(),
        pdfExportRepository: Get.find<PdfExportRepository>(),
        pdfFilesRepository: Get.find<PdfFilesRepository>(),
        wordExportRepository: Get.find<WordExportRepository>(),
        wordFilesRepository: Get.find<WordFilesRepository>(),
        excelExportRepository: Get.find<ExcelExportRepository>(),
        excelFilesRepository: Get.find<ExcelFilesRepository>(),
      ),
    );
  }
}
