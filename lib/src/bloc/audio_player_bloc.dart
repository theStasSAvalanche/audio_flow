import 'package:audioplayers/audioplayers.dart' show DeviceFileSource;
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';

import 'package:audio_flow/src/instruments/audio_player.dart' show player;

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<AudioPlayerPlayEvent>(_onAudioPlayerEvent, transformer: restartable());
  }

  Future<void> _onAudioPlayerEvent(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    player.audioPlayer.play(DeviceFileSource(event.filePath));
  }
}