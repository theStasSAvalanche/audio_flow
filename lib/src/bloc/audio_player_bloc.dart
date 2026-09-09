import 'dart:async' show StreamSubscription;
import 'dart:math' show Random;

import 'package:audio_flow/src/configuration/logger.dart' show logger;
import 'package:audio_flow/src/models/audio_flow_file.dart' show AudioFlowFile;
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart' show Equatable;
import 'package:meta/meta.dart';

import 'package:audio_flow/src/configuration/config.dart'
    show settings, AudioStatus, RepeatStatus;

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  StreamSubscription? tickerSubscription;

  AudioPlayerBloc() : super(AudioPlayerState(isPlaying: false)) {
    on<AudioPlayerStartPlayEvent>(
      _onAudioPlayEvent,
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
    on<AudioPlayerPlayingDetailsEvent>(
      _onAudioUpdateStateEvent,
      transformer: restartable(),
    );
    on<AudioPlayerSeekPositionEvent>(
      _onAudioPlayerSeekPositionEvent,
      transformer: restartable(),
    );
  }

  Future<void> _onAudioPlayEvent(
    AudioPlayerStartPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!await activateAudioSession()) {
      return;
    }
    tickerSubscription?.cancel();

    var track = event.audioTrack;
    if (settings.audioPlaylist.isNotEmpty) {
      track = track ?? settings.audioPlaylist[0];
    }

    if (track == null) {
      return;
    }
    logger.logNS.d('Track album:');
    logger.logNS.d('111: ${track.album}');

    var index = settings.audioPlaylist.indexOf(track);
    settings.setCurrentTrackNumber(index);
    settings.soloud.stopAll();
    await settings.soloud.disposeAllSources();
    settings.audioSource = await settings.soloud.loadFile(track.filePath);
    settings.audioHandle = settings.soloud.play(settings.audioSource!);
    if (event.startPosition != Duration.zero) {
      settings.soloud.seek(settings.audioHandle!, event.startPosition);
    }
    settings.setPlayerStatus(AudioStatus.playing);

    logger.log.d('Now playing: $track');
    var duration = settings.soloud.getLength(settings.audioSource!);
    emit(
      AudioPlayerState(
        audioTrack: track,
        position: Duration.zero,
        duration: duration,
        isPlaying: true,
      ),
    );
    tickerSubscription = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((_) => pollPosition(track: track!));
  }

  Future<void> _onAudioPauseEvent(
    AudioPlayerPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.audioHandle != null) {
      logger.log.d('Pausing...');
      settings.soloud.setPause(settings.audioHandle!, true);
      await deactivateAudioSession();
      settings.setPlayerStatus(AudioStatus.paused);

      final Duration posSeconds = settings.soloud.getPosition(
        settings.audioHandle!,
      );
      emit(
        AudioPlayerState(
          audioTrack: state.audioTrack,
          position: posSeconds,
          duration: state.duration,
          isPlaying: false,
        ),
      );
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
    emit(
      AudioPlayerState(
        audioTrack: state.audioTrack,
        position: state.position,
        duration: state.duration,
        isPlaying: true,
      ),
    );
  }

  Future<void> _onAudioNextEvent(
    AudioPlayerNextEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.audioHandle == null) {
      return;
    }

    if (!await activateAudioSession()) {
      return;
    }

    logger.log.d('Next audio');

    if (settings.repeatMode == RepeatStatus.one) {
      settings.soloud.stopAll();
      await settings.soloud.disposeAllSources();
      playAudioTrack(settings.audioPlaylist[settings.currentTrackNumber]);
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
    playAudioTrack(settings.audioPlaylist[nextTrack]);
  }

  Future<void> _onAudioPreviousEvent(
    AudioPlayerPreviousEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.audioHandle == null) {
      return;
    }

    if (!await activateAudioSession()) {
      return;
    }

    if (settings.repeatMode == RepeatStatus.one) {
      settings.soloud.stopAll();
      await settings.soloud.disposeAllSources();
      playAudioTrack(settings.audioPlaylist[settings.currentTrackNumber]);
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

    playAudioTrack(settings.audioPlaylist[nextTrack]);
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
    emit(
      AudioPlayerState(
        audioTrack: state.audioTrack,
        position: state.position,
        duration: state.duration,
        isPlaying: false,
      ),
    );
  }

  Future<void> _onAudioUpdateStateEvent(
    AudioPlayerPlayingDetailsEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    var duration = settings.soloud.getLength(settings.audioSource!);
    if (event.position <= duration) {
      emit(state.copyWith(position: event.position, duration: duration));
      return;
    }

    logger.log.d('Song was ended, go to next event');
    tickerSubscription?.cancel();
    add(AudioPlayerNextEvent());
  }

  Future<void> _onAudioPlayerSeekPositionEvent(
    AudioPlayerSeekPositionEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (settings.audioHandle != null) {
      settings.soloud.seek(settings.audioHandle!, event.position);
    }
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
    playAudioTrack(settings.audioPlaylist[randomTrack]);
  }

  void playAudioTrack(AudioFlowFile track) {
    add(AudioPlayerStartPlayEvent(audioTrack: track));
  }

  void pollPosition({required AudioFlowFile track}) {
    if (settings.audioHandle == null) {
      return;
    }
    final Duration posSeconds = settings.soloud.getPosition(
      settings.audioHandle!,
    );
    if (!settings.audioSource!.handles.contains(settings.audioHandle!)) {
      tickerSubscription?.cancel();
      add(AudioPlayerNextEvent());
    }

    add(
      AudioPlayerPlayingDetailsEvent(audioTrack: track, position: posSeconds),
    );
  }

  @override
  Future<void> close() {
    tickerSubscription?.cancel();
    return super.close();
  }
}
