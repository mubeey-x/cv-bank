import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cv_bank/core/routes/router.dart';
import 'package:cv_bank/core/theme/app_theme.dart';

class CvBankApp extends ConsumerWidget {
  const CvBankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CV Bank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // Stops a phone set to huge system text from breaking layouts.
        final scale = MediaQuery.textScalerOf(
          context,
        ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: scale.scale(1) / 1,
          maxScaleFactor: 1.3,
          child: child!,
        );
      },
    );
  }
}
