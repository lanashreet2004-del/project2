import 'base_model.dart';

/// OCR extraction result — used across result and text editor flows.
class OcrResultModel extends BaseModel {
  const OcrResultModel({
    required this.id,
    required this.extractedText,
    required this.confidence,
    required this.processedAt,
    required this.imagePath,
    this.language = 'ar',
  });

  final String id;
  final String extractedText;
  final double confidence;
  final DateTime processedAt;
  final String imagePath;
  final String language;

  factory OcrResultModel.fromOcrMap(
    Map<String, dynamic> json, {
    required String imagePath,
  }) {
    return OcrResultModel(
      id: json['id'] as String? ?? 'ocr_unknown',
      extractedText: json['text'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
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
    double? confidence,
    DateTime? processedAt,
    String? imagePath,
    String? language,
  }) {
    return OcrResultModel(
      id: id ?? this.id,
      extractedText: extractedText ?? this.extractedText,
      confidence: confidence ?? this.confidence,
      processedAt: processedAt ?? this.processedAt,
      imagePath: imagePath ?? this.imagePath,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toOcrMap() => {
        'id': id,
        'text': extractedText,
        'confidence': confidence,
        'processed_at': processedAt.toIso8601String(),
        'language': language,
      };

  @override
  Map<String, dynamic> toJson() => {
        ...toOcrMap(),
        'image_path': imagePath,
      };
}
