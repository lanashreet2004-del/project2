import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'error_widget.dart';
import 'loading_widget.dart';

/// Reusable widget for loading / error / content states.
class AsyncStateBuilder extends StatelessWidget {
  const AsyncStateBuilder({
    super.key,
    required this.isLoading,
    required this.builder,
    this.errorMessage,
    this.onRetry,
    this.loadingMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(message: loadingMessage);
    }

    if (errorMessage != null) {
      return AppErrorWidget(message: errorMessage!, onRetry: onRetry);
    }

    return builder(context);
  }
}

/// Obx wrapper that reads loading/error from a GetX controller pattern.
class ObxAsyncState extends StatelessWidget {
  const ObxAsyncState({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.builder,
    this.onRetry,
    this.loadingMessage,
  });

  final RxBool isLoading;
  final RxnString errorMessage;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AsyncStateBuilder(
        isLoading: isLoading.value,
        errorMessage: errorMessage.value,
        onRetry: onRetry,
        loadingMessage: loadingMessage,
        builder: builder,
      ),
    );
  }
}
