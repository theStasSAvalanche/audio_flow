import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'package:audio_flow/src/configuration/logger.dart' show logger;


const immortalizedPath = '/storage/emulated/0/Music/Disturbed/Albums/2015 - Immortalized/';

class AudioFlowFile {
  AudioMetadata? metadata;
  final String filePath;
  final String title;
  String? artist;
  String? album;
  Picture? albumArt;
  String? duration;
  int? trackNumber;

  AudioFlowFile({required this.filePath, required this.title});

  AudioFlowFile.fromMetadata({required AudioMetadata metadata}) :
    filePath = metadata.file.path,
    title = metadata.title ?? metadata.file.path.split(Platform.pathSeparator).last
  {
    this.metadata = metadata;
    artist = metadata.artist;
    album = metadata.album;
    if (metadata.pictures.isNotEmpty) {
      albumArt = metadata.pictures.first;
    }
    duration = metadata.duration.toString();
    trackNumber = metadata.trackNumber;
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    if (artist != null) {
      buffer.write('$artist - ');
    }
    if (album != null) {
      buffer.write('$album - ');
    }
    buffer.write(title);
    return buffer.toString();
  }

  int compareTo(AudioFlowFile other) {
    if (other.artist == null && artist != null) {
      return -1;
    }
    else if (artist == null && other.artist != null) {
      return 1;
    }
    else if (artist != other.artist) {
      return artist!.compareTo(other.artist!);
    }
    else if (artist != null && other.artist != null) {
      
      if (other.album == null && album != null) {
        return -1;
      }
      else if (album == null && other.album != null) {
        return 1;
      }
      else if (album != other.album) {
        return album!.compareTo(other.album!);
      }
      else if (album == other.album) {
        if (trackNumber == null && other.trackNumber != null) {
          return 1;
        }
        else if (trackNumber != null && other.trackNumber == null) {
          return -1;
        }
        else {
          return trackNumber! < other.trackNumber! ? -1 : 1;
        }
      }
    }

    return title.compareTo(other.title);
  }
}

Future<List<AudioFlowFile>> getAudioContent() async {
  logger.log.d('Get audio content started');

  final audioContent = <AudioFlowFile>[];
  final Directory audioDir = Directory(immortalizedPath);

  List<FileSystemEntity> entities = await audioDir.list(recursive: false, followLinks: false).toList();
  for (var entity in entities) {
    if (entity is File && entity.path.endsWith('mp3')) {
      var audioFile = AudioFlowFile.fromMetadata(metadata: await readMp3Tags(entity));
      audioContent.add(audioFile);
    }
  }
  logger.log.d('Tracks found: audioContent');
  audioContent.sort((a, b) => a.compareTo(b));

  return audioContent;
}


Future<AudioMetadata> readMp3Tags(File file) async {
  final metadata = readMetadata(file, getImage: true); 
  logger.log.t('Title: ${metadata.title}');
  logger.log.t('Artist: ${metadata.artist}');
  logger.log.t('Album: ${metadata.album}');
  logger.log.t('Duration: ${metadata.duration}');

  return metadata;
}