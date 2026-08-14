import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _confidencePattern = RegExp(
  'confidenceScore|confidenceLevel|ocrConfidence|\\b[Cc]onfidence\\b',
);

void main() {
  test('production Dart sources contain no OCR confidence identifiers', () {
    final lib = Directory('lib');
    expect(lib.existsSync(), isTrue);

    final hits = <String>[];
    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      if (_confidencePattern.hasMatch(content)) {
        hits.add(entity.path.replaceAll('\\', '/'));
      }
    }

    expect(
      hits,
      isEmpty,
      reason: 'Found confidence identifiers in: $hits',
    );
  });
}
