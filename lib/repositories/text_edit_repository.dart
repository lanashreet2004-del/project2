import '../models/ocr_result_model.dart';
import 'base_repository.dart';

/// Text editing layer — no OCR, API, or storage yet.
/// Ready for future history save, export, and backend sync.
class TextEditRepository extends BaseRepository {
  TextEditRepository({
    required super.apiService,
    required super.storageService,
  });

  OcrResultModel applyTextEdit(OcrResultModel original, String newText) {
    return original.copyWith(extractedText: newText);
  }

  Future<void> saveToHistory(OcrResultModel result) async {
    // Placeholder — persist edited OCR result to local history
  }

  Future<String> exportToJson(OcrResultModel result) async {
    // Placeholder — JSON export of edited text
    return result.toJson().toString();
  }

  Future<String> exportToPdf(OcrResultModel result) async {
    // Placeholder — PDF export of edited text
    return '';
  }

  Future<void> syncToBackend(OcrResultModel result) async {
    // Placeholder — Dio PATCH when backend is ready
  }
}
