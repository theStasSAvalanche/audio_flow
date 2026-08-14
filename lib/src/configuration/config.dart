import 'package:logger/logger.dart' show Level;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'package:audio_flow/src/configuration/logger.dart' show logger;


class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    logger.log.d('Initialize settings singletone class object');
    return _instance;
  }

  // make settings persistent
  static late final SharedPreferences _prefs;

  // Debug and logging
  var isDebug = _prefs.getBool('isDebug') ?? false;
  var logLevel = getLogLevel(_prefs.getString('logLevel'));
  var logFileName = _prefs.getString('logFileName') ?? 'app_logs.txt';

  // Graphically settings
  ThemeMode themeMode = _prefs.getString('themeMode') == 'dark' ? ThemeMode.dark : ThemeMode.light;

  // System settings
  var isAudioFilesPermissionGranted = _prefs.getBool('isAudioFilesPermissionGranted') ?? false;


  void setNewThemeMode(ThemeMode newThemeMode) async {
    themeMode = newThemeMode;
    await _prefs.setString('themeMode', themeMode.name);
  }

  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  static Future<void> initSettings() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // void dispose() async{
  //   logger.log.d('Dispose of settings class. Write prefs to storage');
  //   // await _prefs.setString(_keyUsername, value)
  //   await _prefs.setBool('isDebug', isDebug);
  //   await _prefs.setString('logLevel', logLevel.name);
  //   await _prefs.setString('logFileName', logFileName);
  //   await _prefs.setString('themeMode', themeMode.name);
  //   await _prefs.setBool('isAudioFilesPermissionGranted', isAudioFilesPermissionGranted);
  //   logger.logNS.d('Settings succesfully saved');
  // }
}

Level getLogLevel(String? level) {
  switch (level) {
    case 'trace':
      return Level.trace;
    case 'debug':
      return Level.debug;
    case 'info':
      return Level.info;
    case 'warning':
      return Level.warning;
    case 'error':
      return Level.error;
    case 'fatal':
      return Level.fatal;
    case 'off':
      return Level.off;
    case _:
      return Level.warning;
  }
}

final settings = Settings();