import 'dart:collection';
import 'dart:io';
import 'package:audio_flow/src/configuration/config.dart' show settings;
import 'package:audio_flow/src/models/audio_flow_file.dart';
import 'package:audio_flow/src/models/filesystem_entity.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;

Future<SplayTreeMap<String, List<AudioFlowFile>>> getAudioContentFromFolder(
  String folder,
) async {
  logger.log.d('Get audio content from folder $folder started');

  final audioDatabase = SplayTreeMap<String, List<AudioFlowFile>>();
  final Directory audioDir = Directory(folder);

  List<FileSystemEntity> entities = await audioDir
      .list(recursive: false, followLinks: false)
      .toList();
  var defaultAlbumDir = await getDirectoryAlbumPicture(audioDir);
  for (var entity in entities) {
    if (entity is File && checkEntityIsAudio(entity.path)) {
      try {
        var audioFile = AudioFlowFile.fromMetadata(
          metadata: await readMp3Tags(entity),
        );
        audioFile.directoryPicture = defaultAlbumDir;
        logger.logNS.d('audio file: $audioFile');
        logger.logNS.d('Image: ${audioFile.directoryPicture}');

        audioDatabase.putIfAbsent(folder, () => []).add(audioFile);
      } catch (e) {
        logger.log.e(e);
      }
    }
  }
  logger.logNS.d('The end of scan folder $folder');
  logger.logNS.d(audioDatabase);

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
  try {
    var audioFile = AudioFlowFile.fromMetadata(metadata: await readMp3Tags(f));
    var defaultAlbumDir = await getDirectoryAlbumPicture(Directory(parentDir));
    audioFile.directoryPicture = defaultAlbumDir;
    logger.logNS.d('audio file: $audioFile');
    logger.logNS.d('Image: ${audioFile.directoryPicture}');
    audioDatabase.putIfAbsent(parentDir, () => []).add(audioFile);
  } catch (e) {
    logger.log.e(e);
  }
  // logger.log.d('File is $file');
  // logger.logNS.d(audioDatabase);
  return audioDatabase;
}

Future<AudioMetadata> readMp3Tags(File file) async {
  final metadata = readMetadata(file, getImage: true);
  // logger.log.t('Title: ${metadata.title}');
  // logger.log.t('Artist: ${metadata.artist}');
  // logger.log.t('Album: ${metadata.album}');
  // logger.log.t('Duration: ${metadata.duration}');

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

List<FileSystemCustomEntity> getFoldersRecursivly(
  FileSystemCustomEntity folder,
) {
  List<FileSystemCustomEntity> directories = [];
  var directory = Directory(folder.fullPath);
  late List<FileSystemEntity> entities;
  try {
    entities = directory.listSync(recursive: true);
  } catch (e) {
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

void setParentDirectoriesSemiChecked(
  FileSystemCustomEntity entity,
  String rootDir,
) {
  var items = entity.fullPath.split(Platform.pathSeparator);
  items.removeLast();
  var item = items.join(Platform.pathSeparator);
  while (item != rootDir) {
    var dir = Directory(item);
    var customItem = FileSystemCustomEntity.fromEntity(dir);
    settings.semiCheckedPaths.add(customItem);
    items.removeLast();
    item = items.join(Platform.pathSeparator);
  }
}

Future<String?> getDirectoryAlbumPicture(
  Directory directory,
) async {
  logger.log.d('Get image from folder ${directory.toString()}');
  var imageExtensionsSet = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  if (await directory.exists()) {
    // List all files in the directory (set recursive to true if you want subdirectories)
    List<FileSystemEntity> files = directory.listSync(
      recursive: false,
      followLinks: false,
    );
    logger.logNS.d(files);
    for (var file in files) {
      if (file is File) {
        String extension = file.path.split('.').last.toLowerCase();
        if (imageExtensionsSet.contains(extension)) {
          logger.logNS.d('Image found: ${file.path}');
          return file.path;
        }
      }
    }
  }

  logger.log.d('In directory ${directory.toString()} images not found.');
  return null;
}
