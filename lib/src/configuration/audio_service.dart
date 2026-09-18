import 'package:audio_flow/src/bloc/audio_player_bloc.dart';
import 'package:audio_service/audio_service.dart';

Future<AudioHandler> initAudioFlowAudioService({required AudioPlayerBloc audioPlayerBloc}) async {
  return await AudioService.init(
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


  /// Transforms just_audio events into audio_service PlaybackStates
  // PlaybackState transformEvent(AudioPlayerState state) {
  //   return PlaybackState(
  //     controls: [
  //       MediaControl.rewind,
  //       if (_player.playing) MediaControl.pause else MediaControl.play,
  //       MediaControl.stop,
  //       MediaControl.fastForward,
  //     ],
  //     systemActions: const {
  //       MediaAction.seek,
  //       MediaAction.seekForward,
  //       MediaAction.seekBackward,
  //     },
  //     androidCompactActionIndices: const, // Show play/pause in compact notification view
  //     processingState: const {
  //       ProcessingState.idle: AudioProcessingState.idle,
  //       ProcessingState.loading: AudioProcessingState.loading,
  //       ProcessingState.buffering: AudioProcessingState.buffering,
  //       ProcessingState.ready: AudioProcessingState.ready,
  //       ProcessingState.completed: AudioProcessingState.completed,
  //     }[_player.processingState]!,
  //     playing: _player.playing,
  //     updatePosition: _player.position,
  //     bufferedPosition: _player.bufferedPosition,
  //     speed: _player.speed,
  //     queueIndex: event.currentIndex,
  //   );
  // }
}
