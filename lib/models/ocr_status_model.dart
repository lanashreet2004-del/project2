import '../core/utils/api_exception.dart';
import 'base_model.dart';

/// Backend OCR record status from GET /api/ocr-status/{id}/.
class OcrStatusModel extends BaseModel {
  const OcrStatusModel({
    required this.id,
    required this.status,
    this.extractedText,
    this.errorMessage,
    this.paragraphs = const [],
    this.processedAt,
  });

  final int id;
  final String status;
  final String? extractedText;
  final String? errorMessage;
  final List<String> paragraphs;
  final DateTime? processedAt;

  bool get isPending => status == 'PENDING';
  bool get isProcessing => status == 'PROCESSING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isTerminal => isCompleted || isFailed;

  factory OcrStatusModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '');
    if (id == null) {
      throw ApiException('OCR status response missing id');
    }

    final status = json['status']?.toString();
    if (status == null || status.isEmpty) {
      throw ApiException('OCR status response missing status');
    }

    final document = json['document'];
    final paragraphs = <String>[];
    if (document is Map && document['paragraphs'] is List) {
      for (final item in document['paragraphs'] as List) {
        final text = item?.toString().trim() ?? '';
        if (text.isNotEmpty) paragraphs.add(text);
      }
    }

    DateTime? processedAt;
    final result = json['result'];
    if (result is Map && result['completed_at'] != null) {
      processedAt = DateTime.tryParse(result['completed_at'].toString());
    }
    final metadata = json['metadata'];
    if (processedAt == null && metadata is Map && metadata['created_at'] != null) {
      processedAt = DateTime.tryParse(metadata['created_at'].toString());
    }

    return OcrStatusModel(
      id: id,
      status: status,
      extractedText: json['extracted_text'] as String?,
      errorMessage: json['error_message'] as String?,
      paragraphs: paragraphs,
      processedAt: processedAt,
    );
  }

  /// Map used by existing Result / UploadController pipeline.
  Map<String, dynamic> toOcrResultMap() {
    final text = (extractedText ?? paragraphs.join('\n\n')).trim();
    return {
      'id': id.toString(),
      'text': text,
      'extracted_text': text,
      'processed_at': (processedAt ?? DateTime.now()).toIso8601String(),
      'language': 'ar',
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'extracted_text': extractedText,
        'error_message': errorMessage,
        'document': {'paragraphs': paragraphs},
      };
}
