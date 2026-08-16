import 'package:audioplayers/audioplayers.dart' show DeviceFileSource;
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';

import 'package:audio_flow/src/configuration/config.dart' show settings, AudioStatus;
import 'package:audio_flow/src/instruments/audio_player.dart' show player;

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<AudioPlayerPlayEvent>(_onAudioPlayerEvent, transformer: restartable());
    on<AudioPlayerPauseEvent>(_onAudioPauseEvent, transformer: restartable());
  }

  void _onAudioPlayerEvent(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (event.filePath != null) {
      player.audioPlayer.play(DeviceFileSource(event.filePath!));
    }
    
    else if (settings.playerStatus == AudioStatus.paused && event.filePath == null) {
      player.audioPlayer.resume();
    }
    else {
      // TODO play first audio file from listview
      return;
    }

    settings.setPlayerStatus(AudioStatus.playing);
    emit(AudioPlayerPlaying());
  }

  void _onAudioPauseEvent(
    AudioPlayerPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (settings.playerStatus == AudioStatus.playing) {
      settings.setPlayerStatus(AudioStatus.paused);
      player.audioPlayer.pause();
      emit(AudioPlayerPaused());
    }
  }
}