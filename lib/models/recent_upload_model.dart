/// Recent upload list item data model.
class RecentUploadModel {
  const RecentUploadModel({
    required this.id,
    required this.fileName,
    required this.uploadedAgo,
    required this.thumbnailAsset,
  });

  final String id;
  final String fileName;
  final String uploadedAgo;
  final String thumbnailAsset;
}
