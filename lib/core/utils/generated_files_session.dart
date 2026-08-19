import 'package:get/get.dart';

import '../../controllers/excel_files_controller.dart';
import '../../controllers/json_files_controller.dart';
import '../../controllers/pdf_files_controller.dart';
import '../../controllers/word_files_controller.dart';

/// Reloads generated-file controllers when the authenticated user changes.
class GeneratedFilesSession {
  GeneratedFilesSession._();

  /// Removes the previous account's in-memory lists immediately.
  static void clearRegisteredControllers() {
    if (Get.isRegistered<PdfFilesController>()) {
      Get.find<PdfFilesController>().clearFiles();
    }
    if (Get.isRegistered<WordFilesController>()) {
      Get.find<WordFilesController>().clearFiles();
    }
    if (Get.isRegistered<ExcelFilesController>()) {
      Get.find<ExcelFilesController>().clearFiles();
    }
    if (Get.isRegistered<JsonFilesController>()) {
      Get.find<JsonFilesController>().clearFiles();
    }
  }

  /// Reads the current user's scoped catalogs into any live controllers.
  static Future<void> reloadRegisteredControllers() async {
    if (Get.isRegistered<PdfFilesController>()) {
      await Get.find<PdfFilesController>().loadPdfFiles();
    }
    if (Get.isRegistered<WordFilesController>()) {
      await Get.find<WordFilesController>().loadWordFiles();
    }
    if (Get.isRegistered<ExcelFilesController>()) {
      await Get.find<ExcelFilesController>().loadExcelFiles();
    }
    if (Get.isRegistered<JsonFilesController>()) {
      await Get.find<JsonFilesController>().loadJsonFiles();
    }
  }

  static Future<void> onAuthenticatedUserChanged() async {
    clearRegisteredControllers();
    await reloadRegisteredControllers();
  }
}
