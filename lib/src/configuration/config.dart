import 'package:logger/logger.dart' show Level;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show ThemeMode;


class Settings {
  static final Settings _instance = Settings._internal();

  Settings._internal();

  factory Settings() {
    return _instance;
  }

  static Future<void> initSettings() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // make settings persistent
  static late final SharedPreferences _prefs;

  // Debug and logging
  var isDebug = _prefs.getBool('isDebug') ?? false;
  var logLevel = getLogLevel(_prefs.getString('logLevel'));
  var logFileName = _prefs.getString('logFileName') ?? 'app_log.txt';

  // Application settings
  ThemeMode themeMode = _prefs.getString('themeMode') == 'dark' ? ThemeMode.dark : ThemeMode.light;
  var isAudioFilesPermissionGranted = _prefs.getBool('isAudioFilesPermissionGranted') ?? false;


  void setNewThemeMode(ThemeMode newThemeMode) async {
    themeMode = newThemeMode;
    await _prefs.setString('themeMode', themeMode.name);
  }

  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  void dispose() async{
    await _prefs.setBool('isDebug', isDebug);
    await _prefs.setString('logLevel', logLevel.name);
    await _prefs.setString('logFileName', logFileName);
    await _prefs.setString('themeMode', themeMode.name);
    await _prefs.setBool('isAudioFilesPermissionGranted', isAudioFilesPermissionGranted);
  }
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
      return Level.debug;
  }
}

final settings = Settings();