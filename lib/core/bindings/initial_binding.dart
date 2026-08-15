import 'package:get/get.dart';

import '../../repositories/history_repository.dart';
import '../../repositories/image_edit_repository.dart';
import '../../repositories/image_repository.dart';
import '../../repositories/ocr_repository.dart';
import '../../repositories/result_repository.dart';
import '../../repositories/upload_repository.dart';
import '../../controllers/upload_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/json_export_repository.dart';
import '../../repositories/json_files_repository.dart';
import '../../repositories/pdf_export_repository.dart';
import '../../repositories/pdf_files_repository.dart';
import '../../repositories/word_export_repository.dart';
import '../../repositories/word_files_repository.dart';
import '../../repositories/onboarding_repository.dart';
import '../../repositories/text_edit_repository.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../localization/locale_controller.dart';

/// Registers global services and repositories for dependency injection.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<StorageService>(StorageService(), permanent: true);

    final apiService = Get.find<ApiService>();
    final storageService = Get.find<StorageService>();

    Get.put<AuthRepository>(
      AuthRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      permanent: true,
    );

    final authRepository = Get.find<AuthRepository>();
    authRepository.restoreSession();
    apiService.onUnauthorized = authRepository.handleUnauthorized;

    Get.put<LocaleController>(
      LocaleController(storageService: storageService),
      permanent: true,
    );

    Get.lazyPut<TextEditRepository>(
      () => TextEditRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      fenix: true,
    );

    Get.lazyPut<OnboardingRepository>(
      () => OnboardingRepository(
        apiService: apiService,
        storageService: storageService,
      ),
      fenix: true,
    );

    Get.lazyPut<ImageRepository>(
      () => ImageRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ImageEditRepository>(
      () => ImageEditRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UploadRepository>(
      () => UploadRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.put<UploadController>(
      UploadController(
        repository: Get.find<UploadRepository>(),
        imageRepository: Get.find<ImageRepository>(),
      ),
      permanent: true,
    );

    Get.lazyPut<OcrRepository>(
      () => OcrRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ResultRepository>(
      () => ResultRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<JsonExportRepository>(
      () => JsonExportRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<JsonFilesRepository>(
      () => JsonFilesRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PdfExportRepository>(
      () => PdfExportRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PdfFilesRepository>(
      () => PdfFilesRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<WordExportRepository>(
      () => WordExportRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<WordFilesRepository>(
      () => WordFilesRepository(
        apiService: Get.find<ApiService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );
  }
}
