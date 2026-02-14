import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/gtg_theme.dart';
import 'router.dart';

class GtgApp extends StatefulWidget {
  const GtgApp({super.key});

  @override
  State<GtgApp> createState() => _GtgAppState();
}

class _GtgAppState extends State<GtgApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PROJECT GTG',
      debugShowCheckedModeBanner: false,
      theme: GtgTheme.light(),
      routerConfig: _router,
    );
  }
}
