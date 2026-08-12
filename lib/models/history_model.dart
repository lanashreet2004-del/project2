import 'base_model.dart';

/// Persisted OCR document entry for history.
class HistoryModel extends BaseModel {
  const HistoryModel({
    required this.id,
    required this.imagePath,
    required this.extractedText,
    required this.confidence,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String extractedText;
  final double confidence;
  final DateTime createdAt;

  HistoryModel copyWith({
    String? id,
    String? imagePath,
    String? extractedText,
    double? confidence,
    DateTime? createdAt,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      imagePath: json['image_path'] as String,
      extractedText: json['extracted_text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'image_path': imagePath,
        'extracted_text': extractedText,
        'confidence': confidence,
        'created_at': createdAt.toIso8601String(),
      };
}
