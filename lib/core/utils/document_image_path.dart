/// Helpers for HistoryModel imagePath (local file or remote URL).
class DocumentImagePath {
  DocumentImagePath._();

  static bool isNetworkUrl(String? path) {
    final value = path?.trim().toLowerCase() ?? '';
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static bool isLocalFile(String? path) {
    final value = path?.trim() ?? '';
    if (value.isEmpty || isNetworkUrl(value)) return false;
    return true;
  }
}
