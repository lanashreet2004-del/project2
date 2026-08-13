import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../repositories/auth_repository.dart';
import '../services/storage_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        storageService: Get.find<StorageService>(),
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
