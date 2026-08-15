import '../core/utils/api_exception.dart';
import 'base_model.dart';

/// Response from POST /api/process-ocr/ (HTTP 202).
class OcrProcessResponse extends BaseModel {
  const OcrProcessResponse({
    required this.id,
    required this.status,
    this.message,
  });

  final int id;
  final String status;
  final String? message;

  factory OcrProcessResponse.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '');
    if (id == null) {
      throw ApiException('OCR process response missing id');
    }

    return OcrProcessResponse(
      id: id,
      status: json['status']?.toString() ?? 'PENDING',
      message: json['message'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        if (message != null) 'message': message,
      };
}
