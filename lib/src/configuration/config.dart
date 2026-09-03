import 'package:audio_flow/src/bloc/storage_navigator_bloc.dart' show StorageNavigatorBloc;
import 'package:audio_flow/src/models/audio_flow_file.dart' show AudioFlowFile;
import 'package:audio_flow/src/models/filesystem_entity.dart' show FileSystemCustomEntity;
import 'package:hive_ce/hive.dart';
import 'package:logger/logger.dart' show Level;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show ThemeMode;


enum AudioStatus {
  initial,
  playing,
  paused,
}

enum RepeatStatus {
  off,
  all,
  one,
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

  Future<void> initLazyBox() async {
    lazyBox = await Hive.openLazyBox(settings.playlistName);
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
  var currentTrackNumber = _prefs.getInt('currentTrackNumber') ?? -1;
  var isRandom = _prefs.getBool('isRandom') ?? false;
  var repeatMode = getRepeatStatus(_prefs.getString('repeatMode'));

  // collections of BLoC
  final storageNavigatorBloc = StorageNavigatorBloc();

  // Additional structures
  var playlistName = _prefs.getString('playlistName') ?? 'Playlist 1';
  late LazyBox lazyBox;
  late List<AudioFlowFile> audioPlaylist;
  List<FileSystemCustomEntity> pathsToScan = [];
  String currentScanDir = '/storage/emulated/0';

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

  void setCurrentTrackNumber(int trackNumber) {
    settings.currentTrackNumber = trackNumber;
    _prefs.setInt('currentTrackNumber', trackNumber);
  }

  void changeRandomMode() {
    settings.isRandom = !settings.isRandom;
    _prefs.setBool('isRandom', settings.isRandom);
  }

  void changeRepeatMode() {
    switch (repeatMode) {
      case RepeatStatus.off:
        repeatMode = RepeatStatus.all;
      case RepeatStatus.all:
        repeatMode = RepeatStatus.one;
      case RepeatStatus.one:
        repeatMode = RepeatStatus.off;
    }
    _prefs.setString('isRepeat', settings.repeatMode.name);
  }

  void setPlaylistName(String newPlaylistName) {
    settings.playlistName = newPlaylistName;
    _prefs.setString('playlistName', settings.playlistName);
  }

  void dispose() {
    _prefs.setBool('isDebug', isDebug);
    _prefs.setString('logLevel', logLevel.name);
    _prefs.setString('logFileName', logFileName);
    _prefs.setString('themeMode', themeMode.name);
    _prefs.setBool('isAudioFilesPermissionGranted', isAudioFilesPermissionGranted);
    _prefs.setInt('currentTrackNumber', settings.currentTrackNumber);
    _prefs.setBool('isRandom', settings.isRandom);
    _prefs.setString('isRepeat', settings.repeatMode.name);
    _prefs.setString('playlistName', settings.playlistName);
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

RepeatStatus getRepeatStatus(String? status) {
  switch (status) {
    case 'all':
      return RepeatStatus.all;
    case 'one':
      return RepeatStatus.one;
    case 'standart':
    case '_':
      return RepeatStatus.off;
  }

  return RepeatStatus.off;
}

final settings = Settings();