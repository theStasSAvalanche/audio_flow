part of 'audio_player_bloc.dart';

@immutable
sealed class AudioPlayerEvent {
  const AudioPlayerEvent();
}

class AudioPlayerStartPlayEvent extends AudioPlayerEvent {
  final AudioFlowFile? audioTrack;
  final Duration startPosition;

  const AudioPlayerStartPlayEvent({this.audioTrack, this.startPosition = Duration.zero});
}

class AudioPlayerPauseEvent extends AudioPlayerEvent {}

class AudioPlayerResumeEvent extends AudioPlayerEvent {}

class AudioPlayerStopEvent extends AudioPlayerEvent {}

class AudioPlayerNextEvent extends AudioPlayerEvent {}

class AudioPlayerPreviousEvent extends AudioPlayerEvent {}

class AudioPlayerUpdateStateEvent extends AudioPlayerEvent {
  final AudioFlowFile audioTrack;
  final Duration position;

  const AudioPlayerUpdateStateEvent({
    required this.audioTrack,
    required this.position,
  });
}
