import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'router.dart';

class BeresinApp extends StatelessWidget {
  const BeresinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Beresin — Urus.in',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
