import 'base_model.dart';

/// OCR extraction result — used across result and text editor flows.
class OcrResultModel extends BaseModel {
  const OcrResultModel({
    required this.id,
    required this.extractedText,
    required this.processedAt,
    required this.imagePath,
    this.language = 'ar',
  });

  final String id;
  final String extractedText;
  final DateTime processedAt;
  final String imagePath;
  final String language;

  factory OcrResultModel.fromOcrMap(
    Map<String, dynamic> json, {
    required String imagePath,
  }) {
    return OcrResultModel(
      id: json['id']?.toString() ?? 'ocr_unknown',
      extractedText: (json['text'] as String?) ??
          (json['extracted_text'] as String?) ??
          '',
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : DateTime.now(),
      imagePath: imagePath,
      language: json['language'] as String? ?? 'ar',
    );
  }

  OcrResultModel copyWith({
    String? id,
    String? extractedText,
    DateTime? processedAt,
    String? imagePath,
    String? language,
  }) {
    return OcrResultModel(
      id: id ?? this.id,
      extractedText: extractedText ?? this.extractedText,
      processedAt: processedAt ?? this.processedAt,
      imagePath: imagePath ?? this.imagePath,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toOcrMap() => {
        'id': id,
        'text': extractedText,
        'processed_at': processedAt.toIso8601String(),
        'language': language,
      };

  @override
  Map<String, dynamic> toJson() => {
        ...toOcrMap(),
        'image_path': imagePath,
      };
}
