import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'base_repository.dart';

/// Thrown when gallery or camera picking fails.
class ImagePickException implements Exception {
  ImagePickException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Handles device gallery and camera image selection.
/// Keeps image_picker isolated from controllers and UI.
class ImageRepository extends BaseRepository {
  ImageRepository({
    required super.apiService,
    required super.storageService,
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int _imageQuality = 85;

  /// True when [path] points to an existing, non-empty local file.
  static bool isReadableImage(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty) return false;
    try {
      final file = File(value);
      return file.existsSync() && file.lengthSync() > 0;
    } catch (_) {
      return false;
    }
  }

  /// Opens the device gallery and returns the selected image path.
  Future<String?> pickFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Opens the device camera and returns the captured image path.
  Future<String?> pickFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  /// Recovers an image if Android destroyed MainActivity during camera/gallery.
  /// Android-only; returns null on other platforms or when nothing was lost.
  Future<String?> retrieveLostPickerImage() async {
    if (!Platform.isAndroid) return null;

    try {
      final lost = await _picker.retrieveLostData();
      if (lost.isEmpty) return null;
      if (lost.exception != null) return null;
      if (lost.type == RetrieveType.video) return null;

      final file = lost.file ??
          (lost.files != null && lost.files!.isNotEmpty ? lost.files!.first : null);
      if (file == null) return null;
      if (!isReadableImage(file.path)) return null;
      return file.path;
    } on UnimplementedError {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: _imageQuality,
      );
      if (image == null) return null;
      if (!isReadableImage(image.path)) {
        throw ImagePickException('Failed to pick image: file is not readable.');
      }
      return image.path;
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        throw ImagePickException(
          'Image picker is not ready. Stop the app completely, then run '
          'flutter clean && flutter run.',
        );
      }
      if (e.code == 'photo_access_denied' ||
          e.code == 'camera_access_denied') {
        throw ImagePickException(
          'Permission denied. Allow camera or photo access in settings.',
        );
      }
      throw ImagePickException(
        e.message ?? 'Failed to pick image (${e.code}).',
      );
    } catch (e) {
      if (e is ImagePickException) rethrow;
      throw ImagePickException('Failed to pick image: $e');
    }
  }
}
