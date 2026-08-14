import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Isolated application-documents path for offline tests.
class FakePathProvider extends PathProviderPlatform {
  FakePathProvider(this.applicationDocumentsPath);

  final String applicationDocumentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      applicationDocumentsPath;
}

Future<Directory> createTestDocumentsDir() async {
  final root = await Directory.systemTemp.createTemp('p2_test_');
  final docs = Directory('${root.path}${Platform.pathSeparator}app_docs');
  await docs.create(recursive: true);
  return docs;
}

/// Best-effort cleanup. Windows can keep GetStorage files locked until exit.
Future<void> tryDeleteTestRoot(Directory documentsDir) async {
  final root = documentsDir.parent;
  try {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  } on FileSystemException {
    // Locked by GetStorage on Windows; the OS temp folder is still isolated.
  }
}

Future<File> writeTestImage(
  Directory parent, {
  String name = 'source.jpg',
}) async {
  await parent.create(recursive: true);
  final file = File('${parent.path}${Platform.pathSeparator}$name');
  await file.writeAsBytes(const [0xFF, 0xD8, 0xFF, 0xD9, 0x01, 0x02, 0x03]);
  return file;
}

const forbiddenConfidenceKeys = {
  'confidence',
  'Confidence',
  'confidenceScore',
  'confidenceLevel',
  'ocrConfidence',
};

void expectNoConfidenceFields(
  Map<Object?, Object?> json, {
  String context = 'json',
}) {
  void walk(Object? value, String path) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        expect(
          forbiddenConfidenceKeys.contains(key),
          isFalse,
          reason: '$context contains forbidden key "$key" at $path',
        );
        walk(entry.value, '$path.$key');
      }
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        walk(value[i], '$path[$i]');
      }
    }
  }

  walk(json, context);
}
