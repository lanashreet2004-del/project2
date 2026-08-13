import 'package:get/get.dart';

/// Result of JSON export payload validation.
class JsonExportValidationResult {
  const JsonExportValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  final bool isValid;
  final List<String> errors;

  String get statusTitle => isValid
      ? 'jsonPreview.readyTitle'.tr
      : 'jsonPreview.invalidTitle'.tr;

  String get statusMessage => isValid
      ? 'jsonPreview.readyBody'.tr
      : (errors.isEmpty ? 'jsonPreview.invalidBody'.tr : errors.join('\n'));
}
