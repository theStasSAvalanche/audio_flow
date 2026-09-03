part of 'playlist_files_bloc.dart';

@immutable
sealed class PlaylistFilesEvent {}

class PlaylistFilesFromHive extends PlaylistFilesEvent {
  final String playlistName;

  PlaylistFilesFromHive({required this.playlistName});
}
class PlaylistFilesOpen extends PlaylistFilesEvent {
  final List<FileSystemCustomEntity> pathsToScan;
  PlaylistFilesOpen({required this.pathsToScan}); 
}

class PlaylistFilesClear extends PlaylistFilesEvent {
  final String playlistName;

  PlaylistFilesClear({required this.playlistName});
}
