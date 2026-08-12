import 'package:get/get.dart';

import '../models/image_pick_source.dart';
import '../repositories/image_repository.dart';
import '../repositories/upload_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';

/// Holds selected and edited image paths for the OCR pipeline.
class UploadController extends BaseController {
  UploadController({
    required UploadRepository repository,
    required ImageRepository imageRepository,
  })  : _repository = repository,
        _imageRepository = imageRepository;

  final UploadRepository _repository;
  // ignore: unused_field
  final ImageRepository _imageRepository;

  final RxnString selectedFilePath = RxnString();
  final RxnString editedImagePath = RxnString();
  final Rxn<ImagePickSource> imageSource = Rxn<ImagePickSource>();
  final Rxn<Map<String, dynamic>> ocrResult = Rxn<Map<String, dynamic>>();

  void setEditedImage(String path, {required ImagePickSource source}) {
    editedImagePath.value = path;
    selectedFilePath.value = path;
    imageSource.value = source;
  }

  void setOcrResult(Map<String, dynamic> result) {
    ocrResult.value = result;
  }

  void clearAll() {
    selectedFilePath.value = null;
    editedImagePath.value = null;
    imageSource.value = null;
    ocrResult.value = null;
  }

  Future<void> upload() async {
    final path = editedImagePath.value ?? selectedFilePath.value;
    if (path == null) return;

    final uploadId = await runAsync(
      () => _repository.uploadImage(filePath: path),
    );

    if (uploadId != null) {
      Get.toNamed(AppRoutes.result, arguments: {'resultId': uploadId});
    }
  }
}
