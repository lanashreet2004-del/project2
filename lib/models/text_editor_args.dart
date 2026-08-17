import 'ocr_result_model.dart';

/// Navigation arguments for the shared text editor screen.
class TextEditorArgs {
  const TextEditorArgs({
    required this.ocrResult,
    this.persistToBackend = false,
  });

  final OcrResultModel ocrResult;
  final bool persistToBackend;
}
