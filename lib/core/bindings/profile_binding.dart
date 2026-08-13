import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../repositories/auth_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}
