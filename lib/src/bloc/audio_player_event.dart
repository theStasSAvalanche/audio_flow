part of 'audio_player_bloc.dart';

@immutable
sealed class AudioPlayerEvent {}

class AudioPlayerPlayEvent extends AudioPlayerEvent {
  final int? trackNumber;

  AudioPlayerPlayEvent(this.trackNumber);
}
class AudioPlayerPauseEvent extends AudioPlayerEvent {}
class AudioPlayerResumeEvent extends AudioPlayerEvent {}
class AudioPlayerStopEvent extends AudioPlayerEvent {}
class AudioPlayerNextEvent extends AudioPlayerEvent {}
class AudioPlayerPreviousEvent extends AudioPlayerEvent {}
