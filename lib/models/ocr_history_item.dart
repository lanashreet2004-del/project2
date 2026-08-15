import '../core/utils/api_exception.dart';
import 'history_model.dart';

/// Backend OCR history item from GET /api/ocr-history/.
/// Maps into [HistoryModel] for the existing My Documents UI.
class OcrHistoryItem {
  const OcrHistoryItem({
    required this.id,
    required this.status,
    this.extractedText,
    this.errorMessage,
    this.imageUrl,
    this.imageName,
    this.createdAt,
  });

  final int id;
  final String status;
  final String? extractedText;
  final String? errorMessage;
  final String? imageUrl;
  final String? imageName;
  final DateTime? createdAt;

  factory OcrHistoryItem.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? '');
    if (id == null) {
      throw ApiException('OCR history item missing id');
    }

    final image = json['image'];
    String? imageUrl;
    String? imageName;
    DateTime? uploadedAt;
    if (image is Map) {
      final url = image['url']?.toString().trim();
      if (url != null && url.isNotEmpty) imageUrl = url;
      final name = image['name']?.toString().trim();
      if (name != null && name.isNotEmpty) imageName = name;
      uploadedAt = DateTime.tryParse(image['uploaded_at']?.toString() ?? '');
    }

    final metadata = json['metadata'];
    DateTime? metadataCreatedAt;
    if (metadata is Map) {
      metadataCreatedAt =
          DateTime.tryParse(metadata['created_at']?.toString() ?? '');
      if (imageUrl == null || imageUrl.isEmpty) {
        final source = metadata['source_image']?.toString().trim();
        if (source != null && source.isNotEmpty) imageUrl = source;
      }
    }

    final result = json['result'];
    DateTime? completedAt;
    if (result is Map) {
      completedAt = DateTime.tryParse(result['completed_at']?.toString() ?? '');
    }

    return OcrHistoryItem(
      id: id,
      status: json['status']?.toString() ?? '',
      extractedText: json['extracted_text'] as String?,
      errorMessage: json['error_message'] as String?,
      imageUrl: imageUrl,
      imageName: imageName,
      createdAt: uploadedAt ?? metadataCreatedAt ?? completedAt,
    );
  }

  /// Adapts backend fields to the existing list/details model.
  HistoryModel toHistoryModel() {
    return HistoryModel(
      id: id.toString(),
      imagePath: imageUrl?.trim() ?? '',
      extractedText: extractedText?.trim() ?? '',
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
