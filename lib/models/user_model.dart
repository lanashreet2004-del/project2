import 'base_model.dart';

/// User data model — extend fields when auth is implemented.
class UserModel extends BaseModel {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
  }) : super();

  final String id;
  final String email;
  final String? name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (name != null) 'name': name,
      };

  UserModel copyWith({String? id, String? email, String? name}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}
