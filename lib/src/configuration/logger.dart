import 'dart:io' show File, FileMode;

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart'
  show getApplicationDocumentsDirectory, getExternalStorageDirectory;

import 'package:audio_flow/src/configuration/config.dart' show settings;


class AudioFlowLogger {
  AudioFlowLogger._internal();

  static final _instance = AudioFlowLogger._internal();

  factory AudioFlowLogger() {
    return _instance;
  }

  late Logger log;
  late Logger logNS;
}


final logger = AudioFlowLogger();


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
      RotatingFileOutput(file: logFile),
    ]),
  );
}


class RotatingFileOutput extends LogOutput {
  final File file;
  final int maxFileSize; // in bytes

  RotatingFileOutput({required this.file, this.maxFileSize = 1024 * 1024}); // Default 1MB

  @override
  void output(OutputEvent event) async {
    // Check if the current file exceeds the allowed max limit
    if (await file.exists() && await file.length() >= maxFileSize) {
      _rotateFiles();
    }

    // Write the log event lines to the file
    for (var line in event.lines) {
      await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    }
  }

  void _rotateFiles() {
    final basePath = file.path;
    
    // Deletes the oldest backup file if it exists
    final oldestBackup = File('$basePath.2');
    if (oldestBackup.existsSync()) oldestBackup.deleteSync();

    // Shifts intermediate backup files
    final midBackup = File('$basePath.1');
    if (midBackup.existsSync()) midBackup.renameSync('$basePath.2');

    // Renames current active file to backup sequence
    if (file.existsSync()) file.renameSync('$basePath.1');
  }
}