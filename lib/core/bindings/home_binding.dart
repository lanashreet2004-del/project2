import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/image_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        authRepository: Get.find<AuthRepository>(),
        imageRepository: Get.find<ImageRepository>(),
      ),
    );
  }
}
