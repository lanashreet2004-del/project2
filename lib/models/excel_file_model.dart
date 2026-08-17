import 'base_model.dart';

/// Metadata for a locally exported Excel (.xlsx) file.
class ExcelFileModel extends BaseModel {
  const ExcelFileModel({
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

  factory ExcelFileModel.fromJson(Map<String, dynamic> json) {
    return ExcelFileModel(
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
