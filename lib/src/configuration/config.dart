import 'package:audio_flow/src/models/audio_flow_file.dart' show AudioFlowFile;
import 'package:logger/logger.dart' show Level;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show ThemeMode;


enum AudioStatus {
  initial,
  playing,
  paused,
}

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
  AudioStatus playerStatus = AudioStatus.initial;
  var isAudioFilesPermissionGranted = _prefs.getBool('isAudioFilesPermissionGranted') ?? false;
  var currentTrack = _prefs.getInt('currentTrack') ?? -1;
  var isRandom = _prefs.getBool('isRandom') ?? false;
  var isRepeat = _prefs.getBool('isRepeat') ?? false;

  // Additional structures
  late List<AudioFlowFile> audioPlaylist;

  void setNewThemeMode(ThemeMode newThemeMode) {
    themeMode = newThemeMode;
    _prefs.setString('themeMode', themeMode.name);
  }

  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }

  void setPlayerStatus(AudioStatus newStatus) {
    playerStatus = newStatus;
  }

  void setCurrentTrack(int trackNumber) {
    settings.currentTrack = trackNumber;
    _prefs.setInt('currentTrack', trackNumber);
  }

  void changeRandomMode() {
    settings.isRandom = !settings.isRandom;
    _prefs.setBool('isRandom', settings.isRandom);
  }

  void changeRepeatMode() {
    settings.isRepeat = !settings.isRepeat;
    _prefs.setBool('isRepeat', settings.isRepeat);
  }

  void dispose() {
    _prefs.setBool('isDebug', isDebug);
    _prefs.setString('logLevel', logLevel.name);
    _prefs.setString('logFileName', logFileName);
    _prefs.setString('themeMode', themeMode.name);
    _prefs.setBool('isAudioFilesPermissionGranted', isAudioFilesPermissionGranted);
    _prefs.setInt('currentTrack', settings.currentTrack);
    _prefs.setBool('isRandom', settings.isRandom);
    _prefs.setBool('isRepeat', settings.isRepeat);
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

AudioStatus getPlayerStatus(String? status) {
  switch (status) {
    case 'playing':
      return AudioStatus.playing;
    case 'paused':
      return AudioStatus.paused;
    case 'initial':
    case _:
      return AudioStatus.initial;
  }
}

final settings = Settings();