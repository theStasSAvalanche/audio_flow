import 'dart:io' show File;

import 'package:logger/logger.dart';
// TODO: import rotation_log
import 'package:path_provider/path_provider.dart'
  show getApplicationDocumentsDirectory, getExternalStorageDirectory;

import 'package:audio_flow/src/configuration/config.dart' show Settings;


class AudioFlowLogger {
  AudioFlowLogger._internal();

  static final _instance = AudioFlowLogger._internal();

  factory AudioFlowLogger() {
    return _instance;
  }

  late Logger log;
  late Logger logNS;
}

final settings = Settings();
final logger = AudioFlowLogger();

// We need async init function
// because path_provider methods
// have Future<T> results
Future<void> initLogger() async {
  var directory = await getExternalStorageDirectory();  // Get the application's document directory
  directory = directory ?? await getApplicationDocumentsDirectory();
  final logFile = File('${directory.path}/${settings.logFileName}');

  logger.log = createLogger(logFile: logFile);
  logger.logNS = createLogger(logFile: logFile, prettyCount: 0);
}

Logger createLogger({required File logFile, int prettyCount = 2}) {
  return Logger(
    level: settings.logLevel,
    printer: PrettyPrinter(
      methodCount: prettyCount,
    ),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(file: logFile),
    ]),
  );
}