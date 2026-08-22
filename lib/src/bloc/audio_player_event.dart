part of 'audio_player_bloc.dart';

@immutable
sealed class AudioPlayerEvent {}

class AudioPlayerPlayEvent extends AudioPlayerEvent {
  final String? filePath;

  AudioPlayerPlayEvent(this.filePath);
}
class AudioPlayerPauseEvent extends AudioPlayerEvent {}
class AudioPlayerStopEvent extends AudioPlayerEvent {}
class AudioPlayerNextEvent extends AudioPlayerEvent {}
class AudioPlayerPreviousEvent extends AudioPlayerEvent {}
