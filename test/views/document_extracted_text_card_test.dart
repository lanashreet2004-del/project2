import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:p2/core/localization/app_translations.dart';
import 'package:p2/views/document_details/widgets/document_extracted_text_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
    Get.testMode = false;
  });

  testWidgets('extracted text edit icon calls the existing onEdit action',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: Scaffold(
          body: DocumentExtractedTextCard(
            text: 'تطبيقنا سطر للرقمنة العربية',
            onEdit: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Extracted Text'), findsOneWidget);
    expect(find.byKey(const Key('extracted_text_edit')), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

    await tester.tap(find.byKey(const Key('extracted_text_edit')));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('edit icon is absent when onEdit is not provided', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        home: const Scaffold(
          body: DocumentExtractedTextCard(text: 'hello'),
        ),
      ),
    );

    expect(find.byKey(const Key('extracted_text_edit')), findsNothing);
  });
}
