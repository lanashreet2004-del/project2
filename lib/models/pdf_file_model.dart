import 'base_model.dart';

/// Metadata for a locally exported PDF file.
class PdfFileModel extends BaseModel {
  const PdfFileModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.documentId,
    required this.documentTitle,
    required this.exportedAt,
    this.fileSizeBytes = 0,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String documentId;
  final String documentTitle;
  final DateTime exportedAt;
  final int fileSizeBytes;

  PdfFileModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? documentId,
    String? documentTitle,
    DateTime? exportedAt,
    int? fileSizeBytes,
  }) {
    return PdfFileModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      documentId: documentId ?? this.documentId,
      documentTitle: documentTitle ?? this.documentTitle,
      exportedAt: exportedAt ?? this.exportedAt,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  factory PdfFileModel.fromJson(Map<String, dynamic> json) {
    return PdfFileModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      documentId: json['document_id'] as String? ?? '',
      documentTitle: json['document_title'] as String? ?? 'Untitled Document',
      exportedAt: DateTime.parse(json['exported_at'] as String),
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'file_name': fileName,
        'file_path': filePath,
        'document_id': documentId,
        'document_title': documentTitle,
        'exported_at': exportedAt.toIso8601String(),
        'file_size_bytes': fileSizeBytes,
      };
}
