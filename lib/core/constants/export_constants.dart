/// Constants for local document export paths and naming.
class ExportConstants {
  ExportConstants._();

  static const String exportsFolderName = 'DocumentsExports';
  static const String pdfExportsSubfolder = 'pdf';
  static const String jsonFilePrefix = 'document_';
  static const String jsonFileExtension = '.json';
  static const String pdfFilePrefix = 'document_';
  static const String pdfFileExtension = '.pdf';
  static const String wordExportsSubfolder = 'word';
  static const String wordFilePrefix = 'document_';
  static const String wordFileExtension = '.docx';
  static const String appExportTitle = 'Satr OCR';
  static const String wordFontRegularFamily = 'Noto Sans Arabic';
  static const String wordFontBoldFamily = 'Noto Sans Arabic Bold';

  static const String arabicRegularFontAsset =
      'assets/fonts/NotoSansArabic-Regular.ttf';
  static const String arabicBoldFontAsset =
      'assets/fonts/NotoSansArabic-Bold.ttf';
  static const String arabicTestReportFileName = 'arabic_pdf_test_report.pdf';
}
