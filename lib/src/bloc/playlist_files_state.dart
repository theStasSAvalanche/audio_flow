part of 'playlist_files_bloc.dart';

@immutable
sealed class PlaylistFilesState {
  final List<AudioFlowFile> audioPlaylist;

  const PlaylistFilesState({required this.audioPlaylist});
}

final class PlaylistFilesInitial extends PlaylistFilesState {
  const PlaylistFilesInitial() : super(audioPlaylist: const []);
}

final class PlaylistFilesDataExists extends PlaylistFilesState {
  const PlaylistFilesDataExists(List<AudioFlowFile> audioPlaylist)
    : super(audioPlaylist: audioPlaylist);
}
