import 'base_repository.dart';

/// Repository for AI model integration (Arabic text extraction).
/// Separates OCR/AI logic from controllers for easy model swapping.
class OcrRepository extends BaseRepository {
  OcrRepository({
    required super.apiService,
    required super.storageService,
  });

  Future<Map<String, dynamic>> extractText({
    required String imagePath,
  }) async {
    // Placeholder — integrate local TFLite model or remote AI endpoint.
    // Mock returns extracted text only; the image path is required by the flow.
    return {
      'id': 'ocr_${DateTime.now().millisecondsSinceEpoch}',
      'text':
          'مرحباً بكم في تطبيق مكتوب.\n\n'
          'هذا نص تجريبي مستخرج من الصورة باستخدام تقنية التعرف الضوئي على الحروف.\n'
          'يمكنك تعديل هذا النص بالضغط على زر "تعديل النص".',
      'language': 'ar',
      'processed_at': DateTime.now().toIso8601String(),
    };
  }

  /// Full OCR pipeline — ready for Dio API or on-device model.
  Future<Map<String, dynamic>> processImage({
    required String imagePath,
  }) async {
    // Future: upload via Dio then poll for result, or run local model
    // final response = await apiService.post(ApiConstants.upload, ...);
    return extractText(imagePath: imagePath);
  }

  Future<String> exportToJson({required Map<String, dynamic> data}) async {
    // Placeholder — JSON export logic
    return '{}';
  }

  Future<String> exportToPdf({required Map<String, dynamic> data}) async {
    // Placeholder — PDF export logic
    return '';
  }
}
