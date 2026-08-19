import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/main_shell_controller.dart';
import '../../controllers/pdf_files_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/history_repository.dart';
import '../../repositories/image_repository.dart';
import '../../repositories/pdf_files_repository.dart';
import '../services/storage_service.dart';

/// Registers shell + tab controllers for the primary navigation.
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());

    Get.lazyPut<HomeController>(
      () => HomeController(
        authRepository: Get.find<AuthRepository>(),
        imageRepository: Get.find<ImageRepository>(),
        historyRepository: Get.find<HistoryRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );

    if (Get.isRegistered<PdfFilesController>()) {
      Get.find<PdfFilesController>().loadPdfFiles();
    } else {
      Get.lazyPut<PdfFilesController>(
        () => PdfFilesController(
          repository: Get.find<PdfFilesRepository>(),
        ),
      );
    }

    Get.lazyPut<SettingsController>(
      () => SettingsController(
        storageService: Get.find<StorageService>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
