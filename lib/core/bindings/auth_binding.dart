import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find<AuthRepository>()),
    );
  }
}
