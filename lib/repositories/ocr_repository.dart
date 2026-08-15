import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/utils/api_exception.dart';
import '../models/ocr_process_response.dart';
import '../models/ocr_status_model.dart';
import 'base_repository.dart';

/// OCR against Django process-ocr + ocr-status endpoints.
class OcrRepository extends BaseRepository {
  OcrRepository({
    required super.apiService,
    required super.storageService,
  });

  /// POST multipart `/api/process-ocr/` with field name exactly `image`.
  Future<OcrProcessResponse> processImage({
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: _fileName(imagePath),
        ),
      });

      final response = await apiService.uploadFile<dynamic>(
        ApiConstants.processOcr,
        formData: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      final data = _asMap(response.data);
      return OcrProcessResponse.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET `/api/ocr-status/{id}/`.
  Future<OcrStatusModel> getStatus({required int id}) async {
    try {
      final response = await apiService.get<dynamic>(
        ApiConstants.ocrStatus(id),
      );
      final data = _asMap(response.data);
      return OcrStatusModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Unexpected OCR response.');
  }

  static String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? path : normalized.substring(index + 1);
  }
}
