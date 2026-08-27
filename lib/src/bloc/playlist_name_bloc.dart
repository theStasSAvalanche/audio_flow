import 'package:bloc/bloc.dart';

import 'package:audio_flow/src/configuration/config.dart' show settings;


class PlaylistNameBloc extends Bloc<PlaylistNameChanged, String> {
  PlaylistNameBloc() : super('Playlist') {
    on<PlaylistNameChanged>((event, emit) {
      settings.setPlaylistName(event.newPlaylistName);
      emit(event.newPlaylistName);
    });
  }
}

class PlaylistNameChanged {
  final String newPlaylistName;

  PlaylistNameChanged(this.newPlaylistName);
}