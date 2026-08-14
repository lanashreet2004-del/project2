import '../models/ocr_result_model.dart';
import 'base_repository.dart';

/// Handles fetching and mapping OCR result data.
class ResultRepository extends BaseRepository {
  ResultRepository({
    required super.apiService,
    required super.storageService,
  });

  Future<OcrResultModel> getResult({
    required String id,
    Map<String, dynamic>? ocrData,
    String? imagePath,
  }) async {
    final path = imagePath?.trim() ?? '';
    if (ocrData == null || path.isEmpty) {
      throw Exception('OCR result is incomplete');
    }

    // Placeholder — replace with Dio call when backend is ready
    // final response = await apiService.get('${ApiConstants.results}/$id');
    // return OcrResultModel.fromOcrMap(response.data, imagePath: path);

    return OcrResultModel.fromOcrMap(ocrData, imagePath: path);
  }
}
