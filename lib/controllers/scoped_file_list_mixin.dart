import 'package:get/get.dart';

import '../core/utils/api_exception.dart';
import 'base_controller.dart';

/// Reloads a generated-files RxList without leaking a previous account's items.
///
/// [BaseController.runAsync] turns loading off before the caller can
/// [RxList.assignAll], so Obx that watches `isLoading` never sees the new list.
mixin ScopedFileListMixin on BaseController {
  int _scopedListEpoch = 0;

  /// Drops in-memory items immediately and cancels in-flight loads.
  void clearScopedList<T>(RxList<T> files) {
    _scopedListEpoch++;
    files.clear();
    setLoading(false);
    clearError();
  }

  /// Replaces [files] with the fetch result. Stale loads are ignored.
  Future<void> reloadScopedList<T>(
    RxList<T> files,
    Future<List<T>> Function() fetch,
  ) async {
    final epoch = ++_scopedListEpoch;
    setLoading(true);
    clearError();
    try {
      final data = await fetch();
      if (epoch != _scopedListEpoch) return;
      files.assignAll(data);
    } catch (e) {
      if (epoch != _scopedListEpoch) return;
      files.clear();
      if (e is ApiException) {
        setError(e.message);
      } else {
        setError(e.toString());
      }
    } finally {
      if (epoch == _scopedListEpoch) {
        setLoading(false);
      }
    }
  }
}
