import 'package:get/get.dart';

/// Display helper for document titles — never translates OCR content.
String displayDocumentTitle(String? title) {
  final trimmed = title?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == 'Untitled Document') {
    return 'common.untitledDocument'.tr;
  }
  return trimmed;
}
