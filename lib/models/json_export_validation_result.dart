/// Result of JSON export payload validation.
class JsonExportValidationResult {
  const JsonExportValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  final bool isValid;
  final List<String> errors;

  String get statusTitle => isValid
      ? '✓ JSON Ready For Export'
      : '⚠ Invalid Document Data';

  String get statusMessage => isValid
      ? 'All required fields passed validation checks.'
      : errors.join('\n');
}
