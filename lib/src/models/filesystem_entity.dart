import 'dart:io';

class FileSystemCustomEntity {
  final String name;
  final String fullPath;
  final bool isDir;
  bool isChecked = false;

  FileSystemCustomEntity({required this.name, required this.fullPath, required this.isDir});

  FileSystemCustomEntity.fromEntity(FileSystemEntity entity) :
    name = entity.path.split(Platform.pathSeparator).last,
    fullPath = entity.path,
    isDir = entity is Directory;

  @override
  String toString() {
    return fullPath;
  }

  @override
  int get hashCode => Object.hash(fullPath, name);

  @override
  bool operator ==(Object other) {
    // 1. Check if they are the exact same instance in memory
    if (identical(this, other)) return true;

    // 2. Check if the other object is of the same type and has the same field values
    return other is FileSystemCustomEntity &&
        other.fullPath == fullPath;
  }
}