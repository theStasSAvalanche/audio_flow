import 'dart:collection';

import 'package:audio_flow/src/instruments/storage_audio_reader.dart';
import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:audio_flow/src/models/filesystem_entity.dart'
    show FileSystemCustomEntity;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;


Future<SplayTreeMap<String, List<AudioFlowFile>>> getDictFromHive(String playlist) async {
  logger.log.d('Get dictionary with name: $playlist from Hive');
  var audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  var box = await Hive.openBox(playlist);

  for (var key in box.keys) {
    audioDatabase[key] = List<AudioFlowFile>.from(box.get(key));
    // audioDatabase[key]!.sort((a, b) => a.compareTo(b)); - don't need,
    // because SplayTreeMap already sorted by keys and has sorted List arrays
  }

  return audioDatabase;
} 


Future<List<AudioFlowFile>> getPlaylistFromHive(String playlist) async {
  logger.log.d('Get playlist with name: $playlist from Hive');
  var audioDatabase = await getDictFromHive(playlist);

  final audioContent = audioDatabase.values
      .toList()
      .expand((element) => element)
      .toList();

  return audioContent;
}

Future<void> savePlaylistToHive(
  String playlist,
  SplayTreeMap<String, List<AudioFlowFile>> audioDatabase,
) async {
  logger.log.d('Save playlist with name: $playlist to Hive');
  var box = await Hive.openBox(playlist);
  if (box.isNotEmpty) {
    await box.clear();
  }

  for (var key in audioDatabase.keys) {
    audioDatabase[key]!.sort((a, b) => a.compareTo(b));
    for (var file in audioDatabase[key]!) {
      logger.logNS.i(file.toString());
    }
    await box.put(playlist, audioDatabase[key]);
  }
}

Future<void> clearPlaylistFromHive(String playlist) async {
  var box = await Hive.openBox(playlist);
  await box.clear();
}

Future<void> updatePlaylistToHive(
  List<FileSystemCustomEntity> pathsToScan,
  String playlist,
) async {
  var audioDatabase = await getDictFromHive(playlist);
  late SplayTreeMap<String, List<AudioFlowFile>> audioData;

  for (var entity in pathsToScan) {
    if (entity.isDir) {
      audioData = await getAudioContentFromFolder(entity.fullPath);
    } else {
      audioData = await getAudioContentFromFile(entity.fullPath);
    }

    if (audioData.isEmpty) {
      continue;
    }

    for (var key in audioData.keys) {
      if (!audioDatabase.containsKey(key)) {
        audioDatabase[key] = [...audioData[key]!];
      }

      else {
        for (var value in audioData[key]!) {
          if (!audioDatabase[key]!.contains(value)) {
            audioDatabase[key]!.add(value);
          }
        }
      }
    }
  }

  savePlaylistToHive(playlist, audioDatabase);
}
