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

  /// Opens the device gallery and returns the selected image path.
  Future<String?> pickFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Opens the device camera and returns the captured image path.
  Future<String?> pickFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: _imageQuality,
      );
      return image?.path;
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
