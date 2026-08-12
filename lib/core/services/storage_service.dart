import 'package:get_storage/get_storage.dart';

/// GetStorage wrapper for local persistence and app preferences.
class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clear() async {
    await _box.erase();
  }

  bool hasData(String key) => _box.hasData(key);
}
