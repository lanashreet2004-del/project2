import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/image_pick_source.dart';
import '../repositories/image_edit_repository.dart';
import '../repositories/image_repository.dart';
import '../routes/app_routes.dart';
import 'base_controller.dart';
import 'upload_controller.dart';

/// Presentation logic for the image editor screen.
class ImageEditorController extends BaseController {
  ImageEditorController({
    required ImageEditRepository editRepository,
    required ImageRepository imageRepository,
    required UploadController uploadController,
  })  : _editRepository = editRepository,
        _imageRepository = imageRepository,
        _uploadController = uploadController;

  final ImageEditRepository _editRepository;
  final ImageRepository _imageRepository;
  final UploadController _uploadController;

  final RxnString workingImagePath = RxnString();
  final RxDouble brightness = 1.0.obs;
  final Rx<ImagePickSource> pickSource = ImagePickSource.gallery.obs;

  static const double minBrightness = 0.5;
  static const double maxBrightness = 2.0;

  @override
  void onInit() {
    super.onInit();
    _initFromArguments();
  }

  Future<void> _initFromArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    final path = args?['filePath'] as String?;
    pickSource.value = ImagePickSource.fromString(args?['source'] as String?);

    if (path == null) {
      setError('editor.noImageSelected'.tr);
      return;
    }

    await runAsync(() async {
      workingImagePath.value = await _editRepository.createWorkingCopy(path);
    });
  }

  void setBrightness(double value) => brightness.value = value;

  List<double> get brightnessColorMatrix {
    final value = brightness.value;
    return [
      value, 0, 0, 0, 0,
      0, value, 0, 0, 0,
      0, 0, value, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  Future<void> showCropOptions() async {
    final path = workingImagePath.value;
    if (path == null) return;

    final choice = await Get.bottomSheet<String>(
      _CropOptionsSheet(),
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    if (choice == null) return;

    await runAsync(() async {
      final String? croppedPath;
      switch (choice) {
        case 'free':
          croppedPath = await _editRepository.cropFree(path);
        case 'square':
          croppedPath = await _editRepository.cropSquare(path);
        case 'original':
          croppedPath = await _editRepository.cropOriginal(path);
        default:
          croppedPath = null;
      }
      if (croppedPath != null) {
        workingImagePath.value = croppedPath;
        brightness.value = 1.0;
      }
    });
  }

  Future<void> rotateLeft() async {
    final path = workingImagePath.value;
    if (path == null) return;

    final newPath = await runAsync(() => _editRepository.rotateLeft(path));
    if (newPath != null) workingImagePath.value = newPath;
  }

  Future<void> rotateRight() async {
    final path = workingImagePath.value;
    if (path == null) return;

    final newPath = await runAsync(() => _editRepository.rotateRight(path));
    if (newPath != null) workingImagePath.value = newPath;
  }

  Future<void> retakePhoto() async {
    final source = pickSource.value;
    final path = await runAsync(() {
      return source == ImagePickSource.camera
          ? _imageRepository.pickFromCamera()
          : _imageRepository.pickFromGallery();
    });

    if (path != null) {
      final workingCopy = await _editRepository.createWorkingCopy(path);
      workingImagePath.value = workingCopy;
      brightness.value = 1.0;
    } else if (hasError) {
      Get.snackbar(
        'editor.retakeTitle'.tr,
        errorMessage.value ?? 'home.pickFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> onDone() async {
    final path = workingImagePath.value;
    if (path == null) return;

    final finalPath = await runAsync(
      () => _editRepository.finalizeEdits(path, brightness.value),
    );

    if (finalPath == null) return;

    _uploadController.setEditedImage(finalPath, source: pickSource.value);
    // Replace editor so back from Result returns to Home, not the editor.
    Get.offNamed(AppRoutes.processing);
  }
}

class _CropOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('editor.cropStyle'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.crop_free),
              title: Text('editor.cropFree'.tr),
              onTap: () => Get.back(result: 'free'),
            ),
            ListTile(
              leading: const Icon(Icons.crop_square),
              title: Text('editor.cropSquare'.tr),
              onTap: () => Get.back(result: 'square'),
            ),
            ListTile(
              leading: const Icon(Icons.aspect_ratio),
              title: Text('editor.cropOriginal'.tr),
              onTap: () => Get.back(result: 'original'),
            ),
          ],
        ),
      ),
    );
  }
}
