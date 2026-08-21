import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class AudioFlowFile {
  final String filePath;
  final String title;
  String? artist;
  String? album;
  Uint8List? albumArt;
  String? duration;
  int? trackNumber;

  AudioFlowFile({required this.filePath, required this.title});

  AudioFlowFile.fromMetadata({required AudioMetadata metadata})
    : filePath = metadata.file.path,
      title =
          metadata.title ??
          metadata.file.path.split(Platform.pathSeparator).last,
      artist = metadata.artist,
      album = metadata.album,
      albumArt = metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
      duration = metadata.duration.toString(),
      trackNumber = metadata.trackNumber;

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
    } else if (artist == null && other.artist != null) {
      return 1;
    } else if (artist != other.artist) {
      return artist!.compareTo(other.artist!);
    } else if (artist != null && other.artist != null) {
      if (other.album == null && album != null) {
        return -1;
      } else if (album == null && other.album != null) {
        return 1;
      } else if (album != other.album) {
        return album!.compareTo(other.album!);
      } else if (album == other.album) {
        if (trackNumber == null && other.trackNumber != null) {
          return 1;
        } else if (trackNumber != null && other.trackNumber == null) {
          return -1;
        } else {
          return trackNumber! < other.trackNumber! ? -1 : 1;
        }
      }
    }

    return title.compareTo(other.title);
  }
}
