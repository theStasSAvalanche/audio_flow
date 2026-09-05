import 'dart:math' show Random;

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';

import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus, RepeatStatus;

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
    if (!await activateAudioSession()) {
      return;
    }
    var index = event.trackNumber ?? settings.currentTrackNumber;

    if (index < 0 || index > settings.audioPlaylist.length) {
      index = 0;
    }

    logger.log.d('Now playing: ${settings.audioPlaylist[index].toString()}');
    settings.setCurrentTrackNumber(index);
    settings.setPlayerStatus(AudioStatus.playing);
    settings.soloud.stopAll();
    await settings.soloud.disposeAllSources();
    settings.audioSource = await settings.soloud.playSource(
      file: settings.audioPlaylist[index].filePath,
    );
    settings.audioHandle = settings.soloud.play(settings.audioSource!);
    emit(AudioPlayerPlaying());
  }

  Future<void> _onAudioPauseEvent(
    AudioPlayerPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    // TODO: Pause not works
    if (state is AudioPlayerPlaying && settings.audioHandle != null) {
      logger.log.d('Pausing...');
      settings.soloud.setPause(settings.audioHandle!, true);
      await deactivateAudioSession();
      settings.setPlayerStatus(AudioStatus.paused);
      emit(AudioPlayerPaused());
    }
  }

  Future<void> _onAudioResumeEvent(
    AudioPlayerResumeEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!await activateAudioSession() ||
        settings.audioHandle == null ||
        !settings.soloud.getPause(settings.audioHandle!)) {
      return;
    }

    settings.soloud.setPause(settings.audioHandle!, false);
    settings.setPlayerStatus(AudioStatus.playing);
    emit(AudioPlayerPlaying());
  }

  Future<void> _onAudioNextEvent(
    AudioPlayerNextEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerInitial) {
      return;
    }

    if (state is AudioPlayerPaused && !await activateAudioSession()) {
      return;
    }

    if (settings.repeatMode == RepeatStatus.one) {
      settings.soloud.stopAll();
      await settings.soloud.disposeAllSources();
      playFromIndex(settings.currentTrackNumber);
      return;
    }

    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }

    if (settings.repeatMode == RepeatStatus.off &&
        settings.currentTrackNumber == settings.audioPlaylist.length - 1) {
      add(AudioPlayerStopEvent());
      return;
    }

    var nextTrack =
        (settings.currentTrackNumber + 1) % settings.audioPlaylist.length;
    playFromIndex(nextTrack);
  }

  Future<void> _onAudioPreviousEvent(
    AudioPlayerPreviousEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerInitial) {
      return;
    }

    if (state is AudioPlayerPaused && !await activateAudioSession()) {
      return;
    }

    if (settings.repeatMode == RepeatStatus.one) {
      settings.soloud.stopAll();
      await settings.soloud.disposeAllSources();
      playFromIndex(settings.currentTrackNumber);
      return;
    }

    if (settings.isRandom == true) {
      setRandomTrack();
      return;
    }

    if (settings.repeatMode == RepeatStatus.off &&
        settings.currentTrackNumber == 0) {
      add(AudioPlayerStopEvent());
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
    settings.soloud.stopAll();
    await settings.soloud.disposeAllSources();
    await deactivateAudioSession();
    settings.setCurrentTrackNumber(-1);
    settings.setPlayerStatus(AudioStatus.initial);
    emit(AudioPlayerInitial());
  }

  Future<bool> activateAudioSession() async {
    if (await settings.audioSession.setActive(true)) {
      return true;
    }

    return false;
  }

  Future<void> deactivateAudioSession() async {
    await settings.audioSession.setActive(false);
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
