/// Base contract for all data models.
/// Ensures consistent serialization across the app.
abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson();

  /// Override in subclasses with a factory constructor.
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclass');
  }
}
