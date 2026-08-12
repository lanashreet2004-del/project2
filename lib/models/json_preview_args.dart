import 'history_model.dart';

/// Navigation arguments for the JSON preview screen.
class JsonPreviewArgs {
  const JsonPreviewArgs({
    required this.document,
    required this.status,
    required this.sourceType,
    required this.characterCount,
    required this.wordCount,
    required this.lineCount,
  });

  final HistoryModel document;
  final String status;
  final String sourceType;
  final int characterCount;
  final int wordCount;
  final int lineCount;
}
