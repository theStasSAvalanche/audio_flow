import 'dart:collection';

import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;


Future<List<AudioFlowFile>> getPlaylistFromHive(
  String playlist,
) async {
  logger.log.d('Get playlist with name: $playlist from Hive');
  var audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  var box = await Hive.openBox(playlist);

  for (var key in box.keys) {
    audioDatabase[key] = List<AudioFlowFile>.from(box.get(key));
    // audioDatabase[key]!.sort((a, b) => a.compareTo(b)); - don't need,
    // because SplayTreeMap already sorted by keys and has sorted List arrays
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
    audioDatabase[key]!.sort((a, b) => a.compareTo(b));
    for (var file in audioDatabase[key]!) {
      logger.logNS.i(file.toString());
    }
    await box.put(playlist, audioDatabase[key]);
  }
}

Future<void> clearPlaylistFromHive(
  String playlist,
) async {
  var box = await Hive.openBox(playlist);
  await box.clear();
}

