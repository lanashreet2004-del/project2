import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import 'base_repository.dart';

/// Handles crop, rotate, brightness, and temp file persistence.
class ImageEditRepository extends BaseRepository {
  ImageEditRepository({
    required super.apiService,
    required super.storageService,
  });

  /// Creates a working copy in temp storage for non-destructive editing.
  Future<String> createWorkingCopy(String sourcePath) async {
    final file = File(sourcePath);
    if (!file.existsSync()) {
      throw Exception('Image file not found');
    }
    final tempDir = await getTemporaryDirectory();
    final target = File(
      '${tempDir.path}/edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.copy(target.path);
    return target.path;
  }

  /// Free-form crop.
  Future<String?> cropFree(String path) {
    return _crop(path, lockAspectRatio: false);
  }

  /// Square crop (1:1).
  Future<String?> cropSquare(String path) {
    return _crop(
      path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      lockAspectRatio: true,
    );
  }

  /// Crop using the image's original aspect ratio.
  Future<String?> cropOriginal(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    return _crop(
      path,
      aspectRatio: CropAspectRatio(
        ratioX: decoded.width.toDouble(),
        ratioY: decoded.height.toDouble(),
      ),
      lockAspectRatio: true,
    );
  }

  Future<String?> _crop(
    String path, {
    CropAspectRatio? aspectRatio,
    bool lockAspectRatio = false,
  }) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: aspectRatio,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF5E5CE6),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockAspectRatio,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
    return cropped?.path;
  }

  /// Rotates image 90° counter-clockwise and saves to a new temp file.
  Future<String> rotateLeft(String path) => _rotate(path, angle: -90);

  /// Rotates image 90° clockwise and saves to a new temp file.
  Future<String> rotateRight(String path) => _rotate(path, angle: 90);

  Future<String> _rotate(String path, {required int angle}) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Unable to decode image');

    final rotated = img.copyRotate(decoded, angle: angle.toDouble());
    return _saveImage(rotated);
  }

  /// Bakes brightness into the image file (0.5 – 2.0).
  Future<String> applyBrightness(String path, double brightness) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Unable to decode image');

    final adjusted = img.adjustColor(
      decoded,
      brightness: brightness - 1.0,
    );
    return _saveImage(adjusted);
  }

  /// Final save after all edits — writes brightness into the working file.
  Future<String> finalizeEdits(String path, double brightness) async {
    if ((brightness - 1.0).abs() < 0.01) return path;
    return applyBrightness(path, brightness);
  }

  Future<String> _saveImage(img.Image image) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/edit_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(img.encodeJpg(image, quality: 90));
    return file.path;
  }
}
