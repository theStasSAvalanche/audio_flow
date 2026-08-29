part of 'playlist_files_bloc.dart';

@immutable
sealed class PlaylistFilesEvent {}

class PlaylistFilesFromHive extends PlaylistFilesEvent {
  final String playlistName;

  PlaylistFilesFromHive({required this.playlistName});
}
class PlaylistFilesOpen extends PlaylistFilesEvent {}
class PlaylistFoldersOpen extends PlaylistFilesEvent {
  final List<String> folderPaths;

  PlaylistFoldersOpen({required this.folderPaths});
}
class PlaylistFilesClear extends PlaylistFilesEvent {
  final String playlistName;

  PlaylistFilesClear({required this.playlistName});
}
