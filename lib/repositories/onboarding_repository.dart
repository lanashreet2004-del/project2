import '../core/constants/storage_keys.dart';
import 'base_repository.dart';

/// Handles onboarding completion persistence.
class OnboardingRepository extends BaseRepository {
  OnboardingRepository({
    required super.apiService,
    required super.storageService,
  });

  bool isOnboardingComplete() {
    return storageService.read<bool>(StorageKeys.onboardingComplete) ?? false;
  }

  Future<void> markOnboardingComplete() async {
    await storageService.write(StorageKeys.onboardingComplete, true);
  }
}
