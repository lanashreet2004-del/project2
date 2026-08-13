import 'package:get/get.dart';

import '../core/bindings/auth_binding.dart';
import '../core/bindings/document_details_binding.dart';
import '../core/bindings/document_search_binding.dart';
import '../core/bindings/documents_binding.dart';
import '../core/bindings/image_editor_binding.dart';
import '../core/bindings/json_files_binding.dart';
import '../core/bindings/json_preview_binding.dart';
import '../core/bindings/word_files_binding.dart';
import '../core/bindings/main_shell_binding.dart';
import '../core/bindings/onboarding_binding.dart';
import '../core/bindings/processing_binding.dart';
import '../core/bindings/profile_binding.dart';
import '../core/bindings/result_binding.dart';
import '../core/bindings/text_editor_binding.dart';
import '../core/bindings/upload_binding.dart';
import '../core/constants/storage_keys.dart';
import '../core/navigation/main_navigation.dart';
import '../core/services/storage_service.dart';
import '../views/auth/auth_view.dart';
import '../views/document_details/document_details_view.dart';
import '../views/document_details/document_image_preview_view.dart';
import '../views/documents/documents_view.dart';
import '../views/image_editor/image_editor_view.dart';
import '../views/json_files/json_files_view.dart';
import '../views/json_preview/json_preview_view.dart';
import '../views/word_files/word_files_view.dart';
import '../views/main/main_shell_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/processing/processing_view.dart';
import '../views/profile/profile_view.dart';
import '../views/result/result_view.dart';
import '../views/search/document_search_view.dart';
import '../views/text_editor/text_editor_view.dart';
import '../views/upload/upload_view.dart';
import 'app_routes.dart';

/// GetX route definitions with per-feature bindings.
class AppPages {
  AppPages._();

  static String get initial {
    final storage = StorageService();
    final isComplete =
        storage.read<bool>(StorageKeys.onboardingComplete) ?? false;
    return isComplete ? AppRoutes.home : AppRoutes.onboarding;
  }

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const DocumentSearchView(),
      binding: DocumentSearchBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.imageEditor,
      page: () => const ImageEditorView(),
      binding: ImageEditorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.processing,
      page: () => const ProcessingView(),
      binding: ProcessingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.upload,
      page: () => const UploadView(),
      binding: UploadBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultView(),
      binding: ResultBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.textEditor,
      page: () => const TextEditorView(),
      binding: TextEditorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.jsonPreview,
      page: () => const JsonPreviewView(),
      binding: JsonPreviewBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.documents,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.pdfFiles,
      page: () => const MainTabLaunchView(tabIndex: MainNavigation.pdfFiles),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.jsonFiles,
      page: () => const JsonFilesView(),
      binding: JsonFilesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.wordFiles,
      page: () => const WordFilesView(),
      binding: WordFilesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.documentDetails,
      page: () => const DocumentDetailsView(),
      binding: DocumentDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.documentImagePreview,
      page: () => const DocumentImagePreviewView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const MainTabLaunchView(tabIndex: MainNavigation.settings),
      transition: Transition.fadeIn,
    ),
  ];
}
