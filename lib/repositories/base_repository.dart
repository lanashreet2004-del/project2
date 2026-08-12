import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

/// Base contract for all repositories.
abstract class BaseRepository {
  BaseRepository({
    required this.apiService,
    required this.storageService,
  });

  final ApiService apiService;
  final StorageService storageService;
}
