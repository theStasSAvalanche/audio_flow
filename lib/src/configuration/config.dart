import 'package:flutter/material.dart' show ThemeMode;

import 'package:logger/logger.dart';


class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }


  // Debug and logging
  var isDebug = true;
  var logLevel = Level.debug;
  var logFileName = 'app_logs.txt';

  // Graphically settings
  ThemeMode themeMode = ThemeMode.dark;

  // System settings
  var isAudioFilesPermissionGranted = false;


  void setNewThemeMode(ThemeMode newThemeMode) {
    themeMode = newThemeMode;
  }
}