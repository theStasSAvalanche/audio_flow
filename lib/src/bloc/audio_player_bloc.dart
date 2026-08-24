import 'dart:math' show Random;

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';

import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus, RepeatStatus;
import 'package:audio_flow/src/instruments/audio_player.dart' show player;

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<AudioPlayerPlayEvent>(
      _onAudioPlayerPlayEvent,
      transformer: restartable(),
    );
    on<AudioPlayerPauseEvent>(_onAudioPauseEvent, transformer: restartable());
    on<AudioPlayerResumeEvent>(_onAudioResumeEvent, transformer: restartable());
    on<AudioPlayerNextEvent>(_onAudioNextEvent, transformer: restartable());
    on<AudioPlayerPreviousEvent>(
      _onAudioPreviousEvent,
      transformer: restartable(),
    );
    on<AudioPlayerStopEvent>(_onAudioStopEvent, transformer: restartable());
  }

  Future<void> _onAudioPlayerPlayEvent(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    var index = event.trackNumber ?? settings.currentTrackNumber;

    if (index < 0 || index > settings.audioPlaylist.length) {
      index = 0;
    }

    logger.log.d('Now playing: ${settings.audioPlaylist[index].toString()}');
    settings.setCurrentTrackNumber(index);
    settings.setPlayerStatus(AudioStatus.playing);
    await player.audioPlayer.stop();
    player.audioPlayer.play(
      DeviceFileSource(settings.audioPlaylist[index].filePath),
    );
    emit(AudioPlayerPlaying());
  }

  void _onAudioPauseEvent(
    AudioPlayerPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state is AudioPlayerPlaying) {
      settings.setPlayerStatus(AudioStatus.paused);
      player.audioPlayer.pause();
      emit(AudioPlayerPaused());
    }
  }

  void _onAudioResumeEvent(
    AudioPlayerResumeEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    settings.setPlayerStatus(AudioStatus.playing);
    player.audioPlayer.resume();
    emit(AudioPlayerPlaying());
  }

  Future<void> _onAudioNextEvent (
    AudioPlayerNextEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.repeatMode == RepeatStatus.one) {
      await player.audioPlayer.stop();
      playFromIndex(settings.currentTrackNumber);
      return;
    }

    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }

    if (settings.repeatMode == RepeatStatus.off &&
        settings.currentTrackNumber == settings.audioPlaylist.length - 1) {
      return;
    }
    
    var nextTrack = (settings.currentTrackNumber + 1) % settings.audioPlaylist.length;
    playFromIndex(nextTrack);
  }

  Future<void> _onAudioPreviousEvent(
    AudioPlayerPreviousEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.repeatMode == RepeatStatus.one) {
      await player.audioPlayer.stop();
      playFromIndex(settings.currentTrackNumber);
      return;
    }

    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }
    
    if (settings.repeatMode == RepeatStatus.off &&
        settings.currentTrackNumber == 0) {
      return;
    }

    var nextTrack = 0;
    if (settings.currentTrackNumber != -1) {
      nextTrack =
          (settings.currentTrackNumber - 1 + settings.audioPlaylist.length) %
          settings.audioPlaylist.length;
    }

    playFromIndex(nextTrack);
  }

  Future<void> _onAudioStopEvent(
    AudioPlayerStopEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    settings.setCurrentTrackNumber(-1);
    settings.setPlayerStatus(AudioStatus.initial);
    await player.audioPlayer.stop();
    emit(AudioPlayerInitial());
  }

  void setRandomTrack() {
    var random = Random();
    var randomTrack = random.nextInt(settings.audioPlaylist.length);
    playFromIndex(randomTrack);
  }

  void playFromIndex(int index) {
    add(AudioPlayerPlayEvent(index));
  }
}
