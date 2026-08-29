import 'package:audio_flow/src/configuration/config.dart' show settings;
// import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/instruments/hive_audio_database.dart';
import 'package:audio_flow/src/models/audio_flow_file.dart' show AudioFlowFile;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'playlist_files_event.dart';
part 'playlist_files_state.dart';

class PlaylistFilesBloc extends Bloc<PlaylistFilesEvent, PlaylistFilesState> {
  PlaylistFilesBloc() : super(PlaylistFilesInitial()) {
    on<PlaylistFilesFromHive>(_onPlaylistFilesFromHive);
    on<PlaylistFilesOpen>(_onPlaylistFilesOpen);
    on<PlaylistFoldersOpen>(_onPlaylistFoldersOpen);
    on<PlaylistFilesClear>(_onPlaylistFilesClear);
  }

  Future<void> _onPlaylistFilesFromHive(
    PlaylistFilesFromHive event,
    Emitter<PlaylistFilesState> emit,
  ) async {
    var audioPlaylist = await getPlaylistFromHive(event.playlistName);
    settings.audioPlaylist = audioPlaylist;
    emit(PlaylistFilesDataExists(audioPlaylist: audioPlaylist));
  }

  Future<void> _onPlaylistFilesOpen(
    PlaylistFilesOpen event,
    Emitter<PlaylistFilesState> emit,
  ) async {
    var audioPlaylist = settings.audioPlaylist;
    // TODO: implement

    emit(PlaylistFilesDataExists(audioPlaylist: audioPlaylist));
  }

  Future<void> _onPlaylistFoldersOpen(
    PlaylistFoldersOpen event,
    Emitter<PlaylistFilesState> emit,
  ) async {
    emit(PlaylistFilesLoading());
    var audioPlaylist = settings.audioPlaylist;


    emit(PlaylistFilesDataExists(audioPlaylist: audioPlaylist));
  }

  Future<void> _onPlaylistFilesClear(
    PlaylistFilesClear event,
    Emitter<PlaylistFilesState> emit,
  ) async {
    await clearPlaylistFromHive(event.playlistName);
    settings.audioPlaylist.clear();

    emit(PlaylistFilesInitial());
  }
}