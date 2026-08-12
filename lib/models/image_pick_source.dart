/// Source used when picking an image from Home.
enum ImagePickSource {
  gallery,
  camera;

  static ImagePickSource fromString(String? value) {
    return value == 'camera' ? ImagePickSource.camera : ImagePickSource.gallery;
  }

  String get routeValue => name;
}
