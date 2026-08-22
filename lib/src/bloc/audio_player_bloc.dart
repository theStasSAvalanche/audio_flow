import 'dart:math' show Random;

import 'package:audio_flow/src/configuration/logger.dart' show logger;
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
    on<AudioPlayerNextEvent>(_onAudioNextEvent, transformer: restartable());
    on<AudioPlayerPreviousEvent>(_onAudioPreviousEvent, transformer: restartable());
    on<AudioPlayerStopEvent>(_onAudioStopEvent, transformer: restartable());
  }

  void _onAudioPlayerEvent(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (event.filePath != null) {
      player.audioPlayer.play(DeviceFileSource(event.filePath!));
    }
    
    else if (settings.playerStatus == AudioStatus.paused) {
      player.audioPlayer.resume();
    }
    else if (settings.playerStatus == AudioStatus.initial) {
      playFromIndex(0);
    }
    else {
      playFromIndex(settings.currentTrack == -1 ? 0 : settings.currentTrack);
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

  void _onAudioNextEvent(
    AudioPlayerNextEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }

    var nextTrack = 0;
    if (settings.currentTrack != -1) {
      nextTrack = (settings.currentTrack + 1) % settings.audioPlaylist.length;
    }

    playFromIndex(nextTrack);
  }

  void _onAudioPreviousEvent(
    AudioPlayerPreviousEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }

    var nextTrack = 0;
    if (settings.currentTrack != -1) {
      nextTrack = (settings.currentTrack - 1 + settings.audioPlaylist.length) % settings.audioPlaylist.length;
    }
    
    playFromIndex(nextTrack);
  }

  void _onAudioStopEvent(
    AudioPlayerStopEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    settings.setCurrentTrack(-1);
    settings.setPlayerStatus(AudioStatus.initial);
    player.audioPlayer.stop();
    emit(AudioPlayerInitial());
  }

  void setRandomTrack() {
    var random = Random();
    var randomTrack = random.nextInt(settings.audioPlaylist.length);
    playFromIndex(randomTrack);
  }

  void playFromIndex(int index) {
    var track = settings.audioPlaylist[index];
    settings.setCurrentTrack(index);
    logger.log.d('Now playing: ${track.toString()}');
    add(AudioPlayerPlayEvent(track.filePath));
  }
}