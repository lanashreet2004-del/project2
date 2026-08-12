import 'base_model.dart';

/// Result data model — extend when result feature is implemented.
class ResultModel extends BaseModel {
  const ResultModel({
    required this.id,
    required this.title,
    this.description,
    this.createdAt,
  }) : super();

  final String id;
  final String title;
  final String? description;
  final DateTime? createdAt;

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}
