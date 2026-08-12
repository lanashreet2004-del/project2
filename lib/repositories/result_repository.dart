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
    if (ocrData != null && imagePath != null) {
      return OcrResultModel.fromOcrMap(ocrData, imagePath: imagePath);
    }

    // Placeholder — replace with Dio call when backend is ready
    // final response = await apiService.get('${ApiConstants.results}/$id');
    // return OcrResultModel.fromOcrMap(response.data, imagePath: imagePath ?? '');

    return OcrResultModel(
      id: id,
      extractedText: '',
      confidence: 0.0,
      processedAt: DateTime.now(),
      imagePath: imagePath ?? '',
    );
  }
}
