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
}