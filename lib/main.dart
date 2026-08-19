import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/gtg_app.dart';

import 'package:project_gtg/features/widget_sync/presentation/widget_action_dispatcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Register the native widget background dispatcher
  await registerWidgetDispatcher();

  runApp(const ProviderScope(child: GtgApp()));
}
