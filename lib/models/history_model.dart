import 'base_model.dart';

/// Persisted OCR document entry for history.
class HistoryModel extends BaseModel {
  const HistoryModel({
    required this.id,
    required this.imagePath,
    required this.extractedText,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final String extractedText;
  final DateTime createdAt;

  HistoryModel copyWith({
    String? id,
    String? imagePath,
    String? extractedText,
    DateTime? createdAt,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      imagePath: json['image_path'] as String,
      extractedText: json['extracted_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'image_path': imagePath,
        'extracted_text': extractedText,
        'created_at': createdAt.toIso8601String(),
      };
}
