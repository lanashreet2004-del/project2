import 'package:flutter/material.dart';

import 'upload_option_card.dart';

/// My Documents option card — matches gallery and camera cards.
class MyDocumentsCardWidget extends StatelessWidget {
  const MyDocumentsCardWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UploadOptionCard(
      onTap: onTap,
      icon: Icons.folder_outlined,
      title: 'My Documents',
      subtitle: 'View and manage saved documents',
    );
  }
}
