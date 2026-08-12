import 'base_repository.dart';

/// Handles OCR image upload to backend / AI service.
class UploadRepository extends BaseRepository {
  UploadRepository({
    required super.apiService,
    required super.storageService,
  });

  Future<String> uploadImage({
    required String filePath,
    void Function(int, int)? onProgress,
  }) async {
    // Placeholder — replace with multipart upload when backend is ready
  // final formData = FormData.fromMap({
  //   'file': await MultipartFile.fromFile(filePath),
  // });
  // final response = await apiService.uploadFile(
  //   ApiConstants.upload,
  //   formData: formData,
  //   onSendProgress: onProgress,
  // );
  // return response.data['id'] as String;
    return 'upload_placeholder_id';
  }
}
