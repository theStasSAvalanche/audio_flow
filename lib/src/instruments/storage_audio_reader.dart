import 'dart:collection';
import 'dart:io';
import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:audio_flow/src/models/filesystem_entity.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;

Future<SplayTreeMap<String, List<AudioFlowFile>>> getAudioContentFromFolder(
  String folder,
) async {
  logger.log.d('Get audio content started');

  final audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  final Directory audioDir = Directory(folder);

  List<FileSystemEntity> entities = await audioDir
      .list(recursive: true, followLinks: false)
      .toList();
  for (var entity in entities) {
    if (entity is File && checkEntityIsAudio(entity.path)) {
      var audioFile = AudioFlowFile.fromMetadata(
        metadata: await readMp3Tags(entity),
      );
      File f = File(audioFile.filePath);
      String parentDir = f.parent.path.toString();
      audioDatabase.putIfAbsent(parentDir, () => []).add(audioFile);
    }
  }
  logger.log.d(audioDatabase);
  logger.log.d('Tracks found: audioContent');

  return audioDatabase;
}

Future<SplayTreeMap<String, List<AudioFlowFile>>> getAudioContentFromFile(
  String file,
) async {
  var audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  if (!checkEntityIsAudio(file)) {
    return audioDatabase;
  }

  File f = File(file);
  String parentDir = f.parent.path.toString();
  var audioFile = AudioFlowFile.fromMetadata(metadata: await readMp3Tags(f));
  audioDatabase.putIfAbsent(parentDir, () => []).add(audioFile);
  logger.log.d('File is $file');
  logger.logNS.d(audioDatabase);
  return audioDatabase;
}

Future<AudioMetadata> readMp3Tags(File file) async {
  final metadata = readMetadata(file, getImage: true);
  logger.log.t('Title: ${metadata.title}');
  logger.log.t('Artist: ${metadata.artist}');
  logger.log.t('Album: ${metadata.album}');
  logger.log.t('Duration: ${metadata.duration}');

  return metadata;
}

Future<List<String>> readStorageContents(String folderPath) async {
  // Example path pointing to the public Downloads directory
  String path = folderPath;
  Directory directory = Directory(path);
  List<String> subDirectories = [];

  try {
    if (await directory.exists()) {
      // List all files and folders (set recursive: true to search subfolders)
      List<FileSystemEntity> entities = directory.listSync(recursive: false);

      for (var entity in entities) {
        if (entity is Directory) {
          // logger.log.d('Folder found: ${entity.path}');
          subDirectories.add(entity.toString());
        }
        // else if (entity is File) {
        //   // logger.log.d('File found: ${entity.path}');
        // }
      }
    } else {
      logger.log.w("Directory does not exist");
    }
  } catch (e) {
    logger.log.e("Error reading storage: $e");
  }

  return subDirectories;
}

bool checkEntityIsAudio(String entity) {
  return entity.endsWith('.mp3') || entity.endsWith('.flac');
}


List<FileSystemCustomEntity> getFoldersRecursivly(FileSystemCustomEntity folder) {
  List<FileSystemCustomEntity> directories = [];
  var directory = Directory(folder.fullPath);
  late List<FileSystemEntity> entities;
  try {
    entities = directory.listSync(recursive: true);
  }
  catch (e) {
    logger.log.e(e);
  }

  directories.add(folder);
  for (var entity in entities) {
    if (entity is Directory) {
      directories.add(FileSystemCustomEntity.fromEntity(entity));
    }
  }

  return directories;
}