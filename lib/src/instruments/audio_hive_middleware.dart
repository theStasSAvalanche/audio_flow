import 'dart:collection';

import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/instruments/audio_reader.dart'
    show getAudioContentFromStorage;


const immortalizedPath =
    '/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/';


// List<dynamic> rawList = jsonDecode(response.body);
// List<AudioFlowFile> files = rawList
//     .map((item) => AudioFlowFile.fromJson(item as Map<String, dynamic>))
//     .toList();


Future<List<AudioFlowFile>> getPlaylistFromHive(
  String playlist,
) async {
  logger.log.d('Get playlist with name: $playlist from Hive');
  var audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  var box = await Hive.openBox(playlist);
  for (var key in box.keys) {
    audioDatabase[key] = List<AudioFlowFile>.from(box.get(key));
    audioDatabase[key]!.sort((a, b) => a.compareTo(b));
  }

  final audioContent= audioDatabase.values
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
    await box.put(playlist, audioDatabase[key]);
  }
}

// Future<void> updatePlaylistToHive(
//   String playlist,
//   String key,
//   List<AudioFlowFile> audioData,
// ) async {
//   var box = await Hive.openBox(playlist);
//   await box.put(key, audioData);
// }