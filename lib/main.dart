import 'package:flutter/material.dart';

import 'package:audio_flow/src/configuration/logger.dart' show initLogger, logger;
import 'package:audio_flow/src/ui/basic_material_app.dart' show AudioFlowApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLogger();
  logger.log.i('Application started');
  logger.logNS.i('Let\'s go!!!');
  runApp(const AudioFlowApp());
}
