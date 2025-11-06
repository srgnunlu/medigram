import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medigram/core/theme/app_theme.dart';
import 'package:medigram/core/routes/app_routes.dart';
import 'package:medigram/core/routes/app_pages.dart';

class MedigramApp extends StatelessWidget {
  const MedigramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Medigram',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Translations (future use)
      locale: const Locale('tr', 'TR'),
      fallbackLocale: const Locale('en', 'US'),

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
