import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'playlist_files_event.dart';
part 'playlist_files_state.dart';

class PlaylistFilesBloc extends Bloc<PlaylistFilesEvent, PlaylistFilesState> {
  PlaylistFilesBloc() : super(PlaylistFilesInitial()) {
    on<PlaylistFilesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
