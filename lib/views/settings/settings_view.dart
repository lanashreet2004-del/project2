import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/responsive_layout.dart';

/// Settings screen — UI only.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsiveContainer(
        maxWidth: 600,
        child: Obx(
          () => ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: controller.isDarkMode.value,
                onChanged: (_) => controller.toggleDarkMode(),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                subtitle: Text('Version ${AppConstants.appVersion}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
