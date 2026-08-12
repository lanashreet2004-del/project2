import 'package:get/get.dart';

import '../../controllers/document_details_controller.dart';
import '../../models/history_model.dart';
import '../../repositories/history_repository.dart';
import '../../repositories/pdf_export_repository.dart';
import '../../repositories/word_export_repository.dart';

class DocumentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentDetailsController>(
      () => DocumentDetailsController(
        repository: Get.find<HistoryRepository>(),
        pdfExportRepository: Get.find<PdfExportRepository>(),
        wordExportRepository: Get.find<WordExportRepository>(),
        document: Get.arguments as HistoryModel,
      ),
    );
  }
}
