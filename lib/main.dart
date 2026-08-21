import 'package:flutter/material.dart';


import 'package:audio_flow/src/configuration/logger.dart' show initLogger, logger;
import 'package:audio_flow/src/configuration/config.dart' show AudioStatus, Settings, settings;
import 'package:audio_flow/src/ui/basic_material_app.dart' show AudioFlowApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.initSettings();
  await initLogger();
  settings.setPlayerStatus(AudioStatus.initial);
  logger.log.d('Application started');
  logger.logNS.d('Let\'s go!!!');
  runApp(const AudioFlowApp());
}
