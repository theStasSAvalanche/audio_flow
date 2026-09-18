import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_service/audio_service.dart';

late AudioHandler audioFlowAudioService;

Future<void> initAudioFlowAudioService({
  required AudioPlayerBloc audioPlayerBloc,
}) async {
  audioFlowAudioService = await AudioService.init(
    builder: () => AudioFlowAudioHandler(audioPlayerBloc: audioPlayerBloc),
    config: const AudioServiceConfig(
      // androidNotificationChannelId: 'com.example.audio_flow.channel.audio',
      androidNotificationChannelName: 'AudioFlow Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );
}

class AudioFlowAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerBloc audioPlayerBloc;
  AudioFlowAudioHandler({required this.audioPlayerBloc});

  @override
  Future<void> play() async => audioPlayerBloc.add(AudioPlayerStartPlayEvent());

  @override
  Future<void> pause() async => audioPlayerBloc.add(AudioPlayerPauseEvent());

  @override
  Future<void> stop() async => audioPlayerBloc.add(AudioPlayerStopEvent());

  @override
  Future<void> seek(Duration position) async {
    audioPlayerBloc.add(
      AudioPlayerStartPlayEvent(
        audioTrack: audioPlayerBloc.state.audioTrack,
        startPosition: position,
      ),
    );
  }

  void updatePlaybackState(AudioPlayerState state) {
    // 1. Определяем, какие кнопки показать в зависимости от состояния
    final isPlaying = state.isPlaying;

    playbackState.add(
      PlaybackState(
        // Кнопки, доступные пользователю прямо сейчас
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        // Действия, которые обрабатывает ваш handler (например, жест перемотки на часах)
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: isPlaying,
        processingState: _getProcessingState(state),
        updatePosition: state.position ?? Duration.zero,
        updateTime: DateTime.now(),
      ),
    );
  }

  AudioProcessingState _getProcessingState(AudioPlayerState state) {
    if (state.isPlaying) {
      return AudioProcessingState.ready;
    }

    return AudioProcessingState.idle;
  }
}
