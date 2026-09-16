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

  List<FileSystemEntity> entities =
      await audioDir.list(recursive: false, followLinks: false).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  var defaultAlbumDir = await getDirectoryAlbumPicture(audioDir);
  for (var entity in entities) {
    if (entity is File &&
        settings.uncheckedFiles.contains(
          FileSystemCustomEntity.fromEntity(entity),
        )) {
      continue;
    }

    if (entity is File && checkEntityIsAudio(entity.path)) {
      try {
        var audioFile = AudioFlowFile.fromMetadata(
          metadata: await readMp3Tags(entity),
        );
        audioFile.directoryPicture = defaultAlbumDir;
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

List<FileSystemCustomEntity> getItemsRecursivly(FileSystemCustomEntity folder) {
  List<FileSystemCustomEntity> items = [];
  var directory = Directory(folder.fullPath);
  late List<FileSystemEntity> entities;
  try {
    entities = directory.listSync(recursive: true);
  } catch (e) {
    logger.log.e(e);
    entities = [];
  }

  items.add(folder);
  for (var entity in entities) {
    items.add(FileSystemCustomEntity.fromEntity(entity));
  }

  return items;
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
    entities = [];
  }

  directories.add(folder);
  for (var entity in entities) {
    if (entity is Directory) {
      directories.add(FileSystemCustomEntity.fromEntity(entity));
    }
  }

  return directories;
}

void setParentDirectoriesSemiChecked(FileSystemCustomEntity item) {
  logger.log.d('Start semicheck parents of $item');
  var paths = item.fullPath.split(Platform.pathSeparator);
  paths.removeLast();
  var parent = paths.join(Platform.pathSeparator);
  while (parent != settings.localStorage ||
      parent != settings.externalStorage) {
    var customparent = FileSystemCustomEntity(
      name: paths.last,
      fullPath: parent,
      isDir: true,
    );
    logger.logNS.d('Path to semicheck: $customparent');
    settings.semiCheckedPaths.add(customparent);
    // settings.pathsToScan.remove(customparent);
    paths.removeLast();
    parent = paths.join(Platform.pathSeparator);
  }
  logger.logNS.d('Semi checked paths: ${settings.semiCheckedPaths}');
}

Future<String?> getDirectoryAlbumPicture(Directory directory) async {
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

void setDirectoryContentUncheckedRecursievly(FileSystemCustomEntity entity) {
  if (!entity.isDir) {
    logger.log.w('setDirectoryContentUnchecked not works with files: $entity');
    return;
  }

  var directory = Directory(entity.fullPath);
  var entities = directory.listSync(recursive: true, followLinks: false);
  for (var entity in entities) {
    if (entity is File) {
      var item = FileSystemCustomEntity.fromEntity(entity);
      settings.pathsToScan.remove(item);
      settings.semiCheckedPaths.remove(item);
      settings.uncheckedFiles.remove(item);
    }
  }
}
