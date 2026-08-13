import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/history_repository.dart';
import '../../repositories/image_repository.dart';
import '../services/storage_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        authRepository: Get.find<AuthRepository>(),
        imageRepository: Get.find<ImageRepository>(),
        historyRepository: Get.find<HistoryRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
