import 'package:get/get.dart';

import '../../controllers/image_editor_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../repositories/image_edit_repository.dart';
import '../../repositories/image_repository.dart';

class ImageEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageEditorController>(
      () => ImageEditorController(
        editRepository: Get.find<ImageEditRepository>(),
        imageRepository: Get.find<ImageRepository>(),
        uploadController: Get.find<UploadController>(),
      ),
    );
  }
}
