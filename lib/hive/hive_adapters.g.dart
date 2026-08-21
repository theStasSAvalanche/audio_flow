// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class AudioFlowFileAdapter extends TypeAdapter<AudioFlowFile> {
  @override
  final typeId = 0;

  @override
  AudioFlowFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioFlowFile(
        filePath: fields[0] as String,
        title: fields[1] as String,
      )
      ..artist = fields[2] as String?
      ..album = fields[3] as String?
      ..albumArt = fields[4] as Uint8List?
      ..duration = fields[5] as String?
      ..trackNumber = (fields[6] as num?)?.toInt();
  }

  @override
  void write(BinaryWriter writer, AudioFlowFile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.album)
      ..writeByte(4)
      ..write(obj.albumArt)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.trackNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioFlowFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
