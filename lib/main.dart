import 'package:audio_flow/hive/hive_registrar.g.dart' show HiveRegistrar;
import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_flow/src/configuration/audio_service.dart' show initAudioFlowAudioService;
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:audio_flow/src/configuration/logger.dart' show initLogger, logger;
import 'package:audio_flow/src/configuration/config.dart' show AudioStatus, Settings, settings;
import 'package:audio_flow/src/ui/basic_material_app.dart' show AudioFlowApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Settings.initSettings();
  await settings.initLazyBox();
  // settings.clearAllSettings();
  await initLogger();
  settings.audioSession = await settings.initAudioSession();
  settings.setPlayerStatus(AudioStatus.initial);
  await settings.initSoloud();
  logger.log.d('Soloud state is : ${settings.soloud.isInitialized}');
  final audioPlayerBloc = AudioPlayerBloc();
  await initAudioFlowAudioService(audioPlayerBloc: audioPlayerBloc);
  logger.log.d('Application started');
  logger.logNS.d('Let\'s go!!!');
  runApp(AudioFlowApp(audioPlayerBloc: audioPlayerBloc));
}
