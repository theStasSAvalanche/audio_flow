part of 'playlist_files_bloc.dart';

@immutable
sealed class PlaylistFilesEvent {}

class PlaylistFilesOpen extends PlaylistFilesEvent {}
class PlaylistFoldersOpen extends PlaylistFilesEvent {}
class PlaylistFilesClear extends PlaylistFilesEvent {}
