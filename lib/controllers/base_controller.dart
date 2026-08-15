import 'package:get/get.dart';

import '../core/utils/api_exception.dart';

/// Base GetX controller for MVC presentation layer.
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get hasError => errorMessage.value != null;

  void setLoading(bool value) => isLoading.value = value;

  void setError(String? message) => errorMessage.value = message;

  void clearError() => errorMessage.value = null;

  /// Wraps async operations with standard loading/error handling.
  Future<T?> runAsync<T>(Future<T> Function() action) async {
    setLoading(true);
    clearError();
    try {
      return await action();
    } catch (e) {
      if (e is ApiException) {
        setError(e.message);
      } else {
        setError(e.toString());
      }
      return null;
    } finally {
      setLoading(false);
    }
  }
}
